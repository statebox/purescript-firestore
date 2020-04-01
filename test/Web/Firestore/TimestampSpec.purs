{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.Firestore.TimestampSpec where

import Prelude
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.Timestamp (microseconds, seconds, timestamp, timestampMicroseconds, timestampSeconds)

suite :: Spec Unit
suite = do
  describe "Timestamp" do
    it "preserves the seconds information" $ quickCheck
      \n1 n2 -> timestampSeconds (timestamp (seconds n1) (microseconds n2)) === seconds n1

    it "preserves the microseconds information" $ quickCheck
      \n1 n2 -> timestampMicroseconds (timestamp (seconds n1) (microseconds n2)) === microseconds n2
