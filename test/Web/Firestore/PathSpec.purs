{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.Firestore.PathSpec where

import Prelude
import Data.Array.NonEmpty (fromArray)
import Data.Maybe (isJust, isNothing)
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldSatisfy)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.Path (path)

suite :: Spec Unit
suite = do
  describe "Path" do
    it "is created correctly with an even number of sections" $ quickCheck
      \str1 str2 -> isJust (path =<< fromArray [str1, str2]) === true

    it "is not created correctly with an odd number of sections" $ quickCheck
      \str1 str2 str3 -> isNothing (path =<< fromArray [str1, str2, str3]) === true

    it "is not created correctly with an empty array of sections" do
      (path =<< fromArray []) `shouldSatisfy` isNothing
