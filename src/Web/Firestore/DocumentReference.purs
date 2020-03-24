module Web.Firestore.DocumentReference where

import Prelude
import Data.Function.Uncurried (Fn1, runFn1)

foreign import data DocumentReference :: Type -> Type

foreign import showDocumentReferenceImpl :: forall a. Fn1 (DocumentReference a) String

instance showDocumentReference :: Show a => Show (DocumentReference a) where
  show = runFn1 showDocumentReferenceImpl
