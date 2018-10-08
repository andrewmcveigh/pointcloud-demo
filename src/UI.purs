module UI where

import Data.Function.Uncurried (Fn2, Fn4, Fn5, runFn2, runFn4, runFn5)
import Data.Maybe (Maybe(..))
import Prelude (Unit, map, (<$>))
import Three (Scene)
import Types
import Web.DOM.Document (Document)
import Web.DOM.Node (Node)

import Effect (Effect)
import Signal (Signal, constant)
import Signal.Channel (Channel, send)
import Signal.DOM (DimensionPair)
import Types as Types

foreign import document :: Effect Document

foreign import _getElementById
  :: forall a.
     Fn4 (a -> Maybe a) (Maybe a) Document String (Effect (Maybe Node))

foreign import _nodeOffset
  :: forall c. Fn2 (c -> Signal c) Node (Effect (Signal Offset))

foreign import _renderGlobalControl
  :: forall a.
     Fn5 (Maybe DisplayToggle -> Effect Unit)
         (String -> Maybe DisplayToggle)
         (a -> Maybe a)
         (Maybe a)
         State
         (Effect Node)

foreign import _renderHUD :: Fn2 Node (Array Node) (Effect Unit)

foreign import _renderPointControl
  :: forall a.
     Fn5 (Maybe a -> Maybe DisplayToggle -> Effect Unit)
         (String -> Maybe DisplayToggle)
         (a -> Maybe a)
         (Maybe a)
         Types.Point
         (Effect Node)

foreign import _setCursor :: Fn2 Document String (Effect Unit)


-- |Renders a UI component to control the display state of a point
renderPointControl
  :: Channel UIEvent
  -> Scene
  -> Types.Point
  -> Effect Node
renderPointControl chan scene point = do
  runFn5 _renderPointControl dispatch parseDisplayToggle Just Nothing point
  where
    dispatch (Just (Just obj)) (Just display) =
      send chan (TogglePointDisplay obj display)
    dispatch _ _ =
      send chan NoEvent

-- |Renders a UI component to control the global display state
renderGlobalControl
  :: Channel UIEvent
  -> Scene
  -> State
  -> Effect Node
renderGlobalControl chan scene state = do
  runFn5 _renderGlobalControl dispatch parseDisplayToggle Just Nothing state
  where
    dispatch (Just display) =
      send chan (ToggleGlobalDisplay display)
    dispatch _ =
      send chan NoEvent

-- |Renders a UI overlay into a node, given a list of child nodes
renderHUD :: Node -> Array Node -> Effect Unit
renderHUD = runFn2 _renderHUD

type Offset = { w :: Int, h :: Int, left :: Int, top :: Int }

-- |A signal which contains the node's current Offset
nodeOffset :: Node -> Effect (Signal Offset)
nodeOffset = runFn2 _nodeOffset constant

-- |A signal which contains the node's current width and height.
nodeDimensions :: Node -> Effect (Signal DimensionPair)
nodeDimensions node = map (\{ w, h } -> { w, h }) <$> nodeOffset node

-- |Queries the document for a DOM element with id
getElementById :: Document -> String -> Effect (Maybe Node)
getElementById = runFn4 _getElementById Just Nothing

-- |Sets the cursor icon to the specified value
setCursor :: Document -> String -> (Effect Unit)
setCursor = runFn2 _setCursor
