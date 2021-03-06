{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.Timestamp
( Microseconds
, Seconds
, Timestamp
, microseconds
, seconds
, timestamp
, timestampSeconds
, timestampMicroseconds
) where

import Prelude

import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Test.QuickCheck (class Arbitrary, arbitrary)
import Test.QuickCheck.Gen (suchThat)

newtype Seconds = Seconds Number

derive newtype instance eqSeconds :: Eq Seconds

derive newtype instance ordSeconds :: Ord Seconds

derive newtype instance showSeconds :: Show Seconds

instance boundedSeconds :: Bounded Seconds where
  bottom = Seconds 0.0
  top = Seconds 253402300799.0

instance arbitrarySeconds :: Arbitrary Seconds where
  arbitrary = Seconds <$> arbitrary `suchThat` ((&&) <$> (_ >= 0.0) <*> (_ <= 253402300799.0))

seconds :: Number -> Seconds
seconds n | n > 253402300799.0 = top
          | n <  0.0           = bottom
          | otherwise          = Seconds n

newtype Microseconds = Microseconds Int

derive newtype instance eqMicroseconds :: Eq Microseconds

derive newtype instance ordMicroseconds :: Ord Microseconds

derive newtype instance showMicroseconds :: Show Microseconds

instance boundedMicroseconds :: Bounded Microseconds where
  bottom = Microseconds 0
  top = Microseconds 999999

instance arbitratyMicroseconds :: Arbitrary Microseconds where
  arbitrary = Microseconds <$> arbitrary `suchThat` ((&&) <$> (_ >= 0) <*> (_ <= 999999))

microseconds :: Int -> Microseconds
microseconds i | i > 999999 = top
               | i < 0      = bottom
               | otherwise  = Microseconds i

foreign import data Timestamp :: Type

foreign import timestampImpl :: Fn2 Number Int Timestamp

timestamp :: Seconds -> Microseconds -> Timestamp
timestamp (Seconds n) (Microseconds i) = runFn2 timestampImpl n i

foreign import eqImpl :: Fn2 Timestamp Timestamp Boolean

instance eqTimestamp :: Eq  Timestamp where
  eq = runFn2 eqImpl

foreign import showImpl :: Fn1 Timestamp String

instance showTimestamp :: Show Timestamp where
  show = runFn1 showImpl

instance arbitraryTimestamp :: Arbitrary Timestamp where
  arbitrary = timestamp <$> arbitrary <*> arbitrary

foreign import timestampSecondsImpl :: Fn1 Timestamp Number

timestampSeconds :: Timestamp -> Seconds
timestampSeconds = Seconds <<< runFn1 timestampSecondsImpl

foreign import timestampMicrosecondsImpl :: Fn1 Timestamp Int

timestampMicroseconds :: Timestamp -> Microseconds
timestampMicroseconds = Microseconds <<< runFn1 timestampMicrosecondsImpl
