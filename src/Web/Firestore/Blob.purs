{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.Blob
( Blob
, blob
) where

import Prelude
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Test.QuickCheck (class Arbitrary, arbitrary)

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

instance arbitraryBlob :: Arbitrary Blob where
  arbitrary = blob <$> arbitrary
