module Test.Web.Firestore.PrimitiveValueSpec where

import Prelude
import Data.Argonaut (decodeJson, encodeJson, fromNumber, fromString)
import Data.Either (Either(..))
import Data.Int (toNumber)
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.PrimitiveValue (PrimitiveValue(..))

suite :: Spec Unit
suite = do
  describe "PrimitiveValue" do
    it "parses correctly a boolean" $ quickCheck
      \bool -> decodeJson (encodeJson bool) === Right (PVBoolean bool)

    it "parses correctly an integer" $ quickCheck
      \int -> decodeJson (fromNumber $ toNumber int) === Right (PVInteger int)

    it "parses correctly a float" $ quickCheck
      \float -> decodeJson (fromNumber float) === Right (PVFloat float)

    it "parses correctly a text" $ quickCheck
      \string -> decodeJson (fromString string) === Right (PVText string)
