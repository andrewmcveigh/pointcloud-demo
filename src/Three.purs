module Three where

import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, Fn5, Fn6, runFn1, runFn2, runFn3, runFn4, runFn5, runFn6)
import Data.Maybe (Maybe(..))
import Prelude

import Effect (Effect)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Node (Node)

foreign import data AmbientLight :: Type
foreign import data Camera :: Type
foreign import data Controls :: Type
foreign import data Intersection :: Type
foreign import data Object3D :: Type
foreign import data Point :: Type
foreign import data PointLight :: Type
foreign import data Renderer :: Type
foreign import data Scene :: Type
foreign import data Sprite :: Type
foreign import data Vector2 :: Type
-- foreign import data Vector3 :: Type

type Vector3 = { x :: Number, y :: Number, z :: Number }

instance eqObject3D :: Eq Object3D where
  eq a b = getId a == getId b

instance showPoint :: Show Point where
  show x = "#<Point: " <> show (getId x) <> ">"

instance eqPoint :: Eq Point where
  eq a b = getId a == getId b


instance showSprite :: Show Sprite where
  show x = "#<Sprite: " <> show (getId x) <> ">"

instance eqSprite :: Eq Sprite where
  eq a b = getId a == getId b


data Color = Color Int

type X = Number
type Y = Number
type Z = Number
type PointOpts = { color :: Int, flatShading :: Boolean }
type Intensity = Number
type Distance = Number
type Decay = Number

foreign import _addToScene      :: Fn2 Scene Object3D (Effect Unit)
foreign import _children        :: Fn1 Scene (Effect (Array Object3D))
foreign import _domElement      :: Fn1 Renderer (Effect Node)
foreign import _findObject      :: forall a. Fn4 (a -> Maybe a) (Maybe a) Int Scene (Effect (Maybe Object3D))
foreign import _getId           :: Fn1 Object3D Int
foreign import _intersectionObj :: Fn1 Intersection Object3D
foreign import _intersects      :: Fn3 (Array Object3D) Camera Vector2 (Effect (Array Intersection))
foreign import _length          :: Fn1 Vector3 Number
foreign import _lookAt          :: Fn2 Object3D Vector3 (Effect Unit)
foreign import _mkAmbientLight  :: Fn2 Int Number (Effect AmbientLight)
foreign import _mkCamera        :: Fn4 Number Number Number Number (Effect Camera)
foreign import _mkControls      :: Fn2 Camera Node (Effect Controls)
foreign import _mkPoint         :: Fn5 PointOpts Number X Y Z (Effect Point)
foreign import _mkPointLight    :: Fn4 Int Number Number Number (Effect PointLight)
foreign import _mkRenderer      :: Fn4 Int Number Int Int (Effect Renderer)
foreign import _mkVector2       :: Fn2 Number Number (Effect Vector2)
foreign import _mkVector3       :: Fn3 Number Number Number (Effect Vector3)
foreign import _mkScene         :: Effect Scene
foreign import _mkText          :: Fn6 String Int Int String String Int (Effect Sprite)
foreign import _position        :: Fn1 Object3D Vector3
foreign import _removeFromScene :: Fn2 Scene Object3D (Effect Unit)
foreign import _render          :: Fn3 Renderer Scene Camera (Effect Unit)
foreign import _setColor        :: Fn2 Object3D Int (Effect Unit)
foreign import _setPosition     :: Fn4 Object3D X Y Z (Effect Unit)
foreign import _sizeToNode      :: Fn2 Renderer Node (Effect Unit)
foreign import _updateAspect    :: Fn2 Camera Number (Effect Unit)
foreign import _updateControls  :: Fn1 Controls (Effect Unit)
foreign import _vecAdd          :: Fn2 Vector3 Vector3 Vector3
foreign import _vecSub          :: Fn2 Vector3 Vector3 Vector3

class ThreeObj a where
  addToScene :: Scene -> a -> Effect Unit
  fromObject3D :: Object3D -> a
  getId :: a -> Int
  lookAt :: a -> Vector3 -> Effect Unit
  position :: a -> Vector3
  setColor :: a -> Color -> Effect Unit
  setPosition :: a -> X -> Y -> Z -> Effect Unit
  toObject3D :: a -> Object3D

instance threeObjObject3D :: ThreeObj Object3D where
  addToScene = runFn2 _addToScene
  fromObject3D = identity
  getId = runFn1 _getId
  lookAt = runFn2 _lookAt
  position = runFn1 _position
  setColor x (Color color) = runFn2 _setColor x color
  setPosition = runFn4 _setPosition
  toObject3D = identity

instance threeObjPoint :: ThreeObj Point where
  addToScene scene a = runFn2 _addToScene scene (unsafeCoerce a)
  fromObject3D = unsafeCoerce
  getId = runFn1 _getId <<< unsafeCoerce
  lookAt = runFn2 _lookAt <<< unsafeCoerce
  position = runFn1 _position <<< unsafeCoerce
  setColor x color = setColor (toObject3D x) color
  setPosition = runFn4 _setPosition <<< unsafeCoerce
  toObject3D = unsafeCoerce

instance threeObjPointLight :: ThreeObj PointLight where
  addToScene scene a = runFn2 _addToScene scene (unsafeCoerce a)
  fromObject3D = unsafeCoerce
  getId = runFn1 _getId <<< unsafeCoerce
  lookAt = runFn2 _lookAt <<< unsafeCoerce
  position = runFn1 _position <<< unsafeCoerce
  setPosition = runFn4 _setPosition <<< unsafeCoerce
  setColor x color = setColor (toObject3D x) color
  toObject3D = unsafeCoerce

instance threeObjAmbientLight :: ThreeObj AmbientLight where
  addToScene scene a = runFn2 _addToScene scene (unsafeCoerce a)
  fromObject3D = unsafeCoerce
  getId = runFn1 _getId <<< unsafeCoerce
  lookAt = runFn2 _lookAt <<< unsafeCoerce
  position = runFn1 _position <<< unsafeCoerce
  setColor x color = setColor (toObject3D x) color
  setPosition = runFn4 _setPosition <<< unsafeCoerce
  toObject3D = unsafeCoerce

instance threeObjSprite :: ThreeObj Sprite where
  addToScene scene a = runFn2 _addToScene scene (unsafeCoerce a)
  fromObject3D = unsafeCoerce
  getId = runFn1 _getId <<< unsafeCoerce
  lookAt = runFn2 _lookAt <<< unsafeCoerce
  position = runFn1 _position <<< unsafeCoerce
  setColor x color = setColor (toObject3D x) color
  setPosition = runFn4 _setPosition <<< unsafeCoerce
  toObject3D = unsafeCoerce

instance threeObjCamera :: ThreeObj Camera where
  addToScene scene a = runFn2 _addToScene scene (unsafeCoerce a)
  fromObject3D = unsafeCoerce
  getId = runFn1 _getId <<< unsafeCoerce
  lookAt = runFn2 _lookAt <<< unsafeCoerce
  position = runFn1 _position <<< unsafeCoerce
  setColor x color = setColor (toObject3D x) color
  setPosition = runFn4 _setPosition <<< unsafeCoerce
  toObject3D = unsafeCoerce


children :: Scene -> Effect (Array Object3D)
children = runFn1 _children

domElement :: Renderer -> Effect Node
domElement = runFn1 _domElement

findObject :: Int -> Scene -> Effect (Maybe Object3D)
findObject = runFn4 _findObject Just Nothing

intersectionObj :: Intersection -> Object3D
intersectionObj = runFn1 _intersectionObj

intersects :: Array Object3D -> Camera -> Vector2 -> Effect (Array Intersection)
intersects = runFn3 _intersects

length :: Vector3 -> Number
length = runFn1 _length

mkAmbientLight :: Color -> Number -> Effect AmbientLight
mkAmbientLight (Color color) = runFn2 _mkAmbientLight color

mkCamera :: Number -> Number -> Number -> Number -> Effect Camera
mkCamera = runFn4 _mkCamera

mkControls :: Camera -> Node -> Effect Controls
mkControls = runFn2 _mkControls

mkPoint :: PointOpts -> Number -> X -> Y -> Z -> Effect Point
mkPoint = runFn5 _mkPoint

mkPointLight :: Color -> Intensity -> Distance -> Decay -> Effect PointLight
mkPointLight (Color color) = runFn4 _mkPointLight color

mkRenderer :: Color -> Number -> Int -> Int -> Effect Renderer
mkRenderer (Color color) = runFn4 _mkRenderer color

mkScene :: Effect Scene
mkScene = _mkScene

mkText :: String -> Int -> Color -> String -> String -> Int -> Effect Sprite
mkText text height (Color col) = runFn6 _mkText text height col

mkVector2 :: Number -> Number -> Effect Vector2
mkVector2 = runFn2 _mkVector2

mkVector3 :: Number -> Number -> Number -> Effect Vector3
mkVector3 = runFn3 _mkVector3

removeFromScene :: Scene -> Object3D -> Effect Unit
removeFromScene = runFn2 _removeFromScene

render :: Renderer -> Scene -> Camera -> Effect Unit
render = runFn3 _render

sizeToNode :: Renderer -> Node -> Effect Unit
sizeToNode = runFn2 _sizeToNode

updateAspect :: Camera -> Number -> Effect Unit
updateAspect = runFn2 _updateAspect

updateControls :: Controls -> Effect Unit
updateControls = runFn1 _updateControls

toVector2 :: { x :: Number, y :: Number } -> Effect Vector2
toVector2 { x, y } = mkVector2 x y

vecAdd :: Vector3 -> Vector3 -> Vector3
vecAdd = runFn2 _vecAdd

vecSub :: Vector3 -> Vector3 -> Vector3
vecSub = runFn2 _vecSub
