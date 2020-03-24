module Test.Web.Firestore.PrimitiveValueSpec where

import Prelude
import Data.Maybe (Maybe(..))
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.PrimitiveValue (evalPrimitiveValue, pvBytes, pvBoolean, pvDateTime, pvGeographicalPoint, pvNumber)

suite :: Spec Unit
suite = do
  describe "PrimitiveValue" do
    it "evaluates correctly a bytestring value" $ quickCheck
      \blob -> evalPrimitiveValue
        Just
        (const Nothing)
        (const Nothing)
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvBytes blob)
        === Just blob

    it "evaluates correctly a boolean value" $ quickCheck
      \bool -> evalPrimitiveValue
        (const Nothing)
        Just
        (const Nothing)
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvBoolean bool)
        === Just bool

    it "evaluates correctly a datetime value" $ quickCheck
      \timestamp -> evalPrimitiveValue
        (const Nothing)
        (const Nothing)
        Just
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvDateTime timestamp)
        === Just timestamp

    it "evaluates correctly a geographical point value" $ quickCheck
      \point -> evalPrimitiveValue
        (const Nothing)
        (const Nothing)
        (const Nothing)
        Just
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvGeographicalPoint point)
        === Just point

    it "evaluates correctly a numeric value" $ quickCheck
      \n -> evalPrimitiveValue
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (const Nothing)
        Nothing
        Just
        (const Nothing)
        (const Nothing)
        (pvNumber n)
        === Just n
