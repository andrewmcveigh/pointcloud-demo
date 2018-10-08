module Types where

import Data.Maybe (Maybe(..))
import Prelude (class Eq)
import Three
import Three as Three

data Status = Green | Yellow | Red
derive instance eqStatus :: Eq Status

status :: Status -> { color :: Color, message :: String }
status Green  = { color: Color 6339998,  message: "Good condition" }  -- #60BD9E - HyBird green(ish)
status Yellow = { color: Color 16776960, message: "Possible defect" } -- #FFFF00
status Red    = { color: Color 16711680, message: "Warning!" }        -- #FF0000

type Display = { show      :: Boolean
               , colorized :: Boolean
               , annotated :: Boolean
               }
data DisplayToggle = ShowHide | Colorize | Annotate
derive instance eqDisplayToggle :: Eq DisplayToggle

parseDisplayToggle :: String -> Maybe DisplayToggle
parseDisplayToggle "show"      = Just ShowHide
parseDisplayToggle "colorized" = Just Colorize
parseDisplayToggle "annotated" = Just Annotate
parseDisplayToggle _           = Nothing

data Point
  = Point
      { ref      :: Maybe Three.Point
      , labelRef :: Maybe Sprite
      , label    :: String
      , status   :: Status
      , display  :: Display
      , x        :: X
      , y        :: Y
      , z        :: Z
      }
derive instance eqPoint :: Eq Point

data State
  = State
      { points  :: Array Point
      , label :: String
      , display :: Display
      }
derive instance eqState :: Eq State

data UIEvent
  = NoEvent
  | ToggleGlobalDisplay DisplayToggle
  | TogglePointDisplay Object3D DisplayToggle
