module Web.Firestore.Blob
( Blob
, blob
) where

import Prelude
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)

foreign import data Blob :: Type

foreign import blobImpl :: Fn1 String Blob

blob :: String -> Blob
blob = runFn1 blobImpl

foreign import eqImpl :: Fn2 Blob Blob Boolean

instance eqBlob :: Eq Blob where
  eq = runFn2 eqImpl

foreign import showImpl :: Fn1 Blob String

instance showBlob :: Show Blob where
  show = runFn1 showImpl
