module Test.Web.Firestore.PrimitiveValueSpec where

import Prelude
import Data.Argonaut (decodeJson, fromNumber, fromString, jsonFalse)
import Data.Either (Either(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

import Web.Firestore.PrimitiveValue (PrimitiveValue(..))

suite :: Spec Unit
suite = do
  describe "PrimitiveValue" do
    it "parses correctly a boolean" do
      decodeJson (jsonFalse) `shouldEqual` Right (PVBoolean false)

    it "parses correctly an integer" do
      decodeJson (fromNumber 42.0) `shouldEqual` Right (PVInteger 42)

    it "parses correctly a float" do
      decodeJson (fromNumber 273.15) `shouldEqual` Right (PVFloat 273.15)

    it "parses correctly a text" do
      decodeJson (fromString "foo") `shouldEqual` Right (PVText "foo")
