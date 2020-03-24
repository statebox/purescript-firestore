module Web.Firestore.DocumentReference where

import Prelude
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)

foreign import data DocumentReference :: Type -> Type

foreign import eqImpl :: forall a. Fn2 (DocumentReference a) (DocumentReference a) Boolean

instance eqDocumentReference :: Eq (DocumentReference a) where
  eq = runFn2 eqImpl

foreign import showImpl :: forall a. Fn1 (DocumentReference a) String

instance showDocumentReference :: Show a => Show (DocumentReference a) where
  show = runFn1 showImpl
