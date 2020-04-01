module Web.Firestore.QuerySnapshot where

import Prelude
import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)

foreign import data QuerySnapshot :: Type -> Type

foreign import data QueryDocumentSnapshot :: Type -> Type

foreign import forEachImpl :: forall a. Fn2 (QuerySnapshot a) (QueryDocumentSnapshot a -> Effect Unit) (Effect Unit)

forEach :: forall a. QuerySnapshot a -> (QueryDocumentSnapshot a -> Effect Unit) -> Effect Unit
forEach = runFn2 forEachImpl
