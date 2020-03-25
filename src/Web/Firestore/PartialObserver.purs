module Web.Firestore.PartialObserver where

import Prelude

import Data.Function.Uncurried (Fn3, runFn3)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Effect.Exception (Error)

foreign import data PartialObserver :: Type -> Type

foreign import partialObserverImpl :: forall a. Fn3
  (          a     -> Effect Unit)
  (Nullable (Error -> Effect Unit))
  (Nullable (Unit  -> Effect Unit))
  (PartialObserver a)

partialObserver :: forall a.
     (       a     -> Effect Unit)
  -> (Maybe (Error -> Effect Unit))
  -> (Maybe (Unit  -> Effect Unit))
  -> PartialObserver a
partialObserver next error complete = runFn3 partialObserverImpl next (toNullable error) (toNullable complete)
