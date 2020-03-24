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
