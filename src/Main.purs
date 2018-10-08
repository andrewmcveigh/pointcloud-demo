module Main where

import Data.Array (zip, (:))
import Prelude
import Three
import Types
import UI

import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Signal (Signal, foldp, get, merge, runSignal, sampleOn)
import Signal.Channel (Channel, channel, subscribe)
import Signal.DOM (animationFrame)
import Signals (aspect, clicked, cursor, sceneDimensions)
import Types as Types
import Web.DOM.Node (Node, appendChild)

foreign import undefined :: forall a. a
foreign import spy :: forall a. a

defaultDisplayOptions :: Display
defaultDisplayOptions = { show: true, colorized: true, annotated: false }

fov :: Number
fov = 75.0

near :: Number
near = 10.0

far :: Number
far = 50.0

bgcolor :: Color
bgcolor = Color 6710903 -- #666677

alpha :: Number
alpha = 1.0

lightColor :: Color
lightColor = Color 16777215 -- #ffffff

initState :: State
initState
  = State {
      points: [ Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point A"
                      , status: Red
                      , display: defaultDisplayOptions
                      , x: 1.0, y: 2.0, z: 3.0
                      }
              , Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point B"
                      , status: Green
                      , display: defaultDisplayOptions
                      , x: 9.0, y: 8.0, z: -7.0
                      }
              , Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point C"
                      , status: Yellow
                      , display: defaultDisplayOptions
                      , x: 2.0, y: -4.0, z: 2.0
                      }
              , Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point D"
                      , status: Green
                      , display: defaultDisplayOptions
                      , x: 0.0, y: 0.0, z: 0.0
                      }
              , Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point E"
                      , status: Red
                      , display: defaultDisplayOptions
                      , x: -12.0, y: -1.0, z: 0.0
                      }
              , Point { ref: Nothing
                      , labelRef: Nothing
                      , label: "Point F"
                      , status: Yellow
                      , display: defaultDisplayOptions
                      , x: 6.0, y: 0.0, z: -7.0
                      }
              ]
      , label: "Global"
      , display: { show: true, colorized: true, annotated: true }
      }

-- |Signal of the ever-changing state
stateSignal
  :: Node
  -> Scene
  -> Camera
  -> Channel UIEvent
  -> State
  -> Effect (Signal State)
stateSignal node scene camera chan init = do
  foldp updateState init <<< merge (subscribe chan) <$> clicked node scene camera

-- |Fold over UIEvents and state
updateState
  :: UIEvent -> State -> State

updateState (TogglePointDisplay obj displayToggle) (State state) =
  State (state { points = map toggle state.points })
  where
    toggle original@(Point (p@{ ref })) =
      if (toObject3D <$> ref) == Just obj then
        Point case displayToggle of
          ShowHide -> p { display { show      = not p.display.show      } }
          Colorize -> p { display { colorized = not p.display.colorized } }
          Annotate -> p { display { annotated = not p.display.annotated } }
      else
        original

updateState (ToggleGlobalDisplay displayToggle) (State state) =
  State case displayToggle of
    ShowHide -> state { display { show      = not state.display.show      } }
    Colorize -> state { display { colorized = not state.display.colorized } }
    Annotate -> state { display { annotated = not state.display.annotated } }

updateState NoEvent state = state

lighting :: Effect (Array Object3D)
lighting = do
  ambientLight <- mkAmbientLight lightColor 0.7
  light1 <- mkPointLight lightColor 1.0 0.0 0.0
  light2 <- mkPointLight lightColor 1.0 0.0 0.0
  light3 <- mkPointLight lightColor 1.0 0.0 0.0
  setPosition light1     0.0    200.0  (-200.0)
  setPosition light2   100.0    200.0    100.0
  setPosition light3 (-100.0) (-200.0) (-100.0)
  pure [ toObject3D ambientLight
       , toObject3D light1
       , toObject3D light2
       , toObject3D light3
       ]

addAllToScene :: forall a. ThreeObj a => Scene -> Array a -> Effect Unit
addAllToScene scene objs =
  traverse (addToScene scene) objs $> unit

-- |Draw initial state into scene
drawState :: State -> Scene -> Effect State
drawState (State state) scene = do
  points <- traverse point state.points
  addAllToScene scene points
  labels <- traverse label state.points
  let points' = map setRefs (zip state.points (zip points labels))
  pure (State (state { points = points' }))
  where
    setRefs ((Point p) /\ oRef /\ lRef) =
      Point (p { ref = Just oRef, labelRef = Just lRef })
    point (Point { status, x, y, z }) =
      let { color, message } = Types.status status
          (Color col) = color in
        mkPoint { color: col, flatShading: true } 1.0 x y z
    label (Point { status, x, y, z }) =
      let { message } = Types.status status in do
        text <- mkText message 2 (Color 0) "Arial" "bold" 90
        setPosition text x (y - 1.5) (z + 0.5)
        pure text

-- |Render current state
renderState :: Scene -> State -> Effect Unit
renderState scene (State { display, points }) =
  traverse renderPoint points $> unit
  where
    renderObject true  (Just ref) = addToScene      scene ref
    renderObject false (Just ref) = removeFromScene scene ref
    renderObject _      Nothing   = pure unit
    renderColor  true  color (Just ref) = setColor ref color
    renderColor  false _     (Just ref) = setColor ref (Color 0)
    renderColor  _     _      _         = pure unit
    renderPoint (Point { ref, labelRef, status, display: { show, colorized, annotated } }) =
      renderObject (display.annotated && annotated) (toObject3D <$> labelRef) *>
      renderObject (display.show && show) (toObject3D <$> ref) *>
      renderColor (display.colorized && colorized) (Types.status status).color ref

drawUI
  :: Channel UIEvent
  -> Scene
  -> Node
  -> State
  -> Effect Unit
drawUI chan scene node state@(State { points }) = do
  pointControls <- traverse (renderPointControl chan scene) points
  globalControl <- renderGlobalControl chan scene state
  renderHUD node (globalControl : pointControls)

main :: Effect Unit
main = do
  document' <- document
  sceneNode <- getElementById document' "scene"
  uiNode    <- getElementById document' "hud"
  case (Tuple uiNode sceneNode) of
    (Just uiDiv /\ Just node) -> do
      aspect'   <- get =<< aspect
      { w, h }  <- get =<< sceneDimensions
      camera    <- mkCamera fov aspect' near far
      setPosition camera 0.0 0.0 30.0
      scene     <- mkScene
      renderer  <- mkRenderer bgcolor alpha w h
      domNode   <- domElement renderer
      appendChild domNode node $> unit
      controls  <- mkControls camera domNode
      lighting' <- lighting
      addAllToScene scene lighting'
      state     <- drawState initState scene
      aspects   <- aspect
      frames    <- animationFrame
      chan      <- channel NoEvent
      drawUI chan scene uiDiv state
      states    <- stateSignal node scene camera chan state
      runSignal (map (drawUI chan scene uiDiv) states)
      _         <- cursor document' node scene camera
      runSignal (map (doSize renderer node camera) aspects)
      runSignal (map
                  (doRender renderer scene camera controls)
                  (sampleOn frames states))
    _ -> pure unit
  where
    doSize renderer rootNode camera aspect' =
      updateAspect camera aspect' *>
      sizeToNode renderer rootNode
    doRender renderer scene camera controls state =
      renderState scene state *>
      updateControls controls *>
      render renderer scene camera
