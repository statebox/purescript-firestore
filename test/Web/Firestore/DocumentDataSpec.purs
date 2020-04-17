{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.Firestore.DocumentDataSpec where

import Prelude
import Data.Tuple.Nested ((/\))
import Foreign.Object (fromFoldable)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldNotEqual)

import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (primitiveDocument)
import Web.Firestore.PrimitiveValue (pvNumber, pvText)

suite :: Spec Unit
suite = do
  describe "DocumentData" do
    it "consider a document equal to itself" do
      let doc = DocumentData (fromFoldable [ "text" /\ primitiveDocument (pvText   "a string")
                                           , "int"  /\ primitiveDocument (pvNumber 273.15)
                                           ])
      doc `shouldEqual` doc

    it "recognizes two documents as different" do
      let doc1 = DocumentData (fromFoldable [ "text" /\ primitiveDocument (pvText   "a string")
                                            , "int"  /\ primitiveDocument (pvNumber 273.15)
                                            ])
          doc2 = DocumentData (fromFoldable [ "text" /\ primitiveDocument (pvText   "another string")
                                            , "int"  /\ primitiveDocument (pvNumber 273.15)
                                            ])
      doc1 `shouldNotEqual` doc2
