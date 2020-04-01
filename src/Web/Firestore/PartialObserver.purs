{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

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
