module Web.Firestore.CollectionReference where

import Prelude
import Data.Function.Uncurried (Fn1, runFn1)

foreign import data CollectionReference :: Type -> Type

foreign import showImpl :: forall a. Fn1 (CollectionReference a) String

instance showCollectionReference :: Show (CollectionReference a) where
  show = runFn1 showImpl
