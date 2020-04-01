{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.GeographicalPoint (GeographicalPoint, point) where

import Prelude
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Test.QuickCheck (class Arbitrary, arbitrary)

import Web.Firestore.LatLon (Lat, Lon)

foreign import data GeographicalPoint :: Type

foreign import pointImpl :: Fn2 Lat Lon GeographicalPoint

point :: Lat -> Lon -> GeographicalPoint
point = runFn2 pointImpl

foreign import eqImpl :: Fn2 GeographicalPoint GeographicalPoint Boolean

instance eqGeographicalPoint :: Eq GeographicalPoint where
  eq = runFn2 eqImpl

foreign import showImpl :: Fn1 GeographicalPoint String

instance showGeographicalPoint :: Show GeographicalPoint where
  show = runFn1 showImpl

instance arbitraryGeographicalPoint :: Arbitrary GeographicalPoint where
  arbitrary = point <$> arbitrary <*> arbitrary
