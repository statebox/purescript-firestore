module Web.Firestore.QuerySnapshot where

import Prelude

import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Web.Firestore.DocumentReference (DocumentReference)
import Web.Firestore.SnapshotOptions (SnapshotOptions)

foreign import data QuerySnapshot :: Type -> Type

foreign import data QueryDocumentSnapshot :: Type -> Type

foreign import forEachImpl :: forall a. Fn2 (QuerySnapshot a) (QueryDocumentSnapshot a -> Effect Unit) (Effect Unit)

forEach :: forall a. QuerySnapshot a -> (QueryDocumentSnapshot a -> Aff Unit) -> Aff Unit
forEach querySnapshot callback = liftEffect $ runFn2 forEachImpl querySnapshot (launchAff_ <<< callback)

foreign import queryDocumentDataImpl :: forall a. Fn2 (QueryDocumentSnapshot a) (Nullable SnapshotOptions) a

queryDocumentData :: forall a. QueryDocumentSnapshot a -> Maybe SnapshotOptions -> a
queryDocumentData documentSnapshot options = runFn2 queryDocumentDataImpl documentSnapshot (toNullable options)

foreign import queryDocumentReferenceImpl :: forall a. Fn1 (QueryDocumentSnapshot a) (DocumentReference a)

queryDocumentReference :: forall a. QueryDocumentSnapshot a -> DocumentReference a
queryDocumentReference = runFn1 queryDocumentReferenceImpl
