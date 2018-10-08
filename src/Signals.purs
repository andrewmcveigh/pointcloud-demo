module Signals where

import Data.Array (uncons)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Prelude (Unit, bind, map, negate, pure, (*), (+), (-), (/), (<$>), (=<<))
import Signal (Signal, constant, get, map2, unwrap)
import Signal.DOM (CoordinatePair, DimensionPair, MouseButton(..), mouseButtonPressed, mousePos)
import Three (Camera, Intersection, Scene, children, intersectionObj, intersects, toVector2)
import Types (DisplayToggle(..), UIEvent(..))
import UI (document, getElementById, nodeDimensions, nodeOffset, setCursor)
import Web.DOM.Document (Document)
import Web.DOM.Node (Node)

relativeMousePos :: Node -> Effect (Signal CoordinatePair)
relativeMousePos node = do
  absPos <- mousePos
  offset <- nodeOffset node
  pure (map2 adjust absPos offset)
  where
    adjust { x, y } { left, top } = { x: x - left, y: y - top }

intersectionSignal :: Node -> Scene -> Camera -> Effect (Signal (Array Intersection))
intersectionSignal node scene camera = do
  coords     <- relativeMousePos node
  dimensions <- nodeDimensions node
  unwrap (map intersectsChildren (map2 adjust coords dimensions))
  where
    adjust { x, y } { w, h } =
      { x:   (toNumber x / toNumber w) * 2.0 - 1.0
      , y: - (toNumber y / toNumber h) * 2.0 + 1.0
      }
    intersectsChildren coord = do
      objs <- children scene
      vec2 <- toVector2 coord
      intersects objs camera vec2

sceneDimensions :: Effect (Signal DimensionPair)
sceneDimensions = do
  document' <- document
  sceneNode <- getElementById document' "scene"
  case sceneNode of
    Just node -> nodeDimensions node
    Nothing   -> pure (constant { w: 0, h: 0 })

aspect :: Effect (Signal Number)
aspect = do
  dimensions <- sceneDimensions
  pure (map aspect' dimensions)
  where
    aspect' { w, h } = (toNumber w / toNumber h)

cursor :: Document -> Node -> Scene -> Camera -> Effect (Signal Unit)
cursor document node scene camera = do
  signal <- intersectionSignal node scene camera
  unwrap (toggleCursor <$> signal)
  where
    toggleCursor [] = setCursor document "default"
    toggleCursor _  = setCursor document "pointer"

clicked
  :: Node
  -> Scene
  -> Camera
  -> Effect (Signal UIEvent)
clicked node scene camera = do
  click <- mouseButtonPressed MouseLeftButton
  unwrap (map clickedPoint click)
  where
    clickedPoint true = do
      xs <- get =<< intersectionSignal node scene camera
      case uncons xs of
        Just { head, tail } ->
          pure (TogglePointDisplay (intersectionObj head) Annotate)
        Nothing -> pure NoEvent
    clickedPoint false = pure NoEvent
