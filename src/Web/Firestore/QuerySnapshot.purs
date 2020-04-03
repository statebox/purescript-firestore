module Web.Firestore.QuerySnapshot where

import Prelude
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)

import Web.Firestore.SnapshotOptions (SnapshotOptions(..))

foreign import data QuerySnapshot :: Type -> Type

foreign import data QueryDocumentSnapshot :: Type -> Type

foreign import forEachImpl :: forall a. Fn2 (QuerySnapshot a) (QueryDocumentSnapshot a -> Effect Unit) (Effect Unit)

forEach :: forall a. QuerySnapshot a -> (QueryDocumentSnapshot a -> Effect Unit) -> Effect Unit
forEach = runFn2 forEachImpl

foreign import queryDocumentDataImpl :: forall a. Fn2 (QueryDocumentSnapshot a) (Nullable SnapshotOptions) a

queryDocumentData :: forall a. QueryDocumentSnapshot a -> Maybe SnapshotOptions -> a
queryDocumentData documentSnapshot options = runFn2 queryDocumentDataImpl documentSnapshot (toNullable options)
