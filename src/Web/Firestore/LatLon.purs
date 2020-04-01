{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.LatLon
( Lat
, Lon
, lat
, lon
) where

import Prelude
import Data.Maybe (Maybe(..))
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (suchThat)

newtype Lat = Lat Number

derive newtype instance eqLat :: Eq Lat

derive newtype instance ordLat :: Ord Lat

instance boundedLat :: Bounded Lat where
  bottom = Lat (-90.0)
  top = Lat 90.0

lat :: Number -> Maybe Lat
lat n =
  if n >= -90.0 && n <= 90.0
  then Just $ Lat n
  else Nothing

instance showLat :: Show Lat where
  show (Lat n) = show n

instance arbitraryLat :: Arbitrary Lat where
  arbitrary = Lat <$> arbitrary `suchThat` (\n -> n >= -90.0 && n <= 90.0)

newtype Lon = Lon Number

derive newtype instance eqLon :: Eq Lon

derive newtype instance ordLon :: Ord Lon

instance boundedLon :: Bounded Lon where
  bottom = Lon (-180.0)
  top = Lon 180.0

lon :: Number -> Maybe Lon
lon n =
  if n >= -180.0 && n <= 180.0
  then Just $ Lon n
  else Nothing

instance showLon :: Show Lon where
  show (Lon n) = show n

instance arbitraryLon :: Arbitrary Lon where
  arbitrary = Lon <$> arbitrary `suchThat` (\n -> n >= -180.0 && n <= 180.0)
