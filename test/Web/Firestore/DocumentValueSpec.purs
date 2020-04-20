{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.Firestore.DocumentValueSpec where

import Prelude
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldNotEqual)

import Web.Firestore.DocumentValue (primitiveDocument)
import Web.Firestore.PrimitiveValue (pvNumber, pvText)

suite :: Spec Unit
suite = do
  describe "DocumentValue" do
    it "recognizes two string primitive values as different" do
      let val1 = primitiveDocument (pvText "a string")
          val2 = primitiveDocument (pvText "another string")

      val1 `shouldNotEqual` val2

    it "recognizes two numeric primitive values as different" do
      let val1 = primitiveDocument (pvNumber 10.0)
          val2 = primitiveDocument (pvNumber 273.15)

      val1 `shouldNotEqual` val2
