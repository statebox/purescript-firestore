{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

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
