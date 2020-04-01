{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.Firestore.PrimitiveValueSpec where

import Prelude
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence)
import Effect.Class (liftEffect)
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual, shouldNotEqual)
import Test.Spec.QuickCheck (quickCheck)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (doc, firestore, initializeApp)
import Web.Firestore.DocumentPath (pathFromString)
import Web.Firestore.PrimitiveValue (evalPrimitiveValue, pvBytes, pvBoolean, pvDateTime, pvGeographicalPoint, pvNull, pvNumber, pvReference, pvText)

suite :: Spec Unit
suite = do
  describe "PrimitiveValue" do
    it "evaluates correctly a boolean value" $ quickCheck
      \bool -> evalPrimitiveValue
        Just
        (const Nothing)
        (const Nothing)
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvBoolean bool)
        === Just bool

    it "evaluates correctly a bytestring value" $ quickCheck
      \blob -> evalPrimitiveValue
        (const Nothing)
        Just
        (const Nothing)
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvBytes blob)
        === Just blob

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

    it "evaluates correctly a null value" do
      evalPrimitiveValue
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (Just unit)
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (pvNull)
        `shouldEqual` Just unit

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

    it "evaluates correctly a reference value" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-other-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail $ show "we should have a reference to a document"
                Just docRef -> evalPrimitiveValue
                  (const Nothing)
                  (const Nothing)
                  (const Nothing)
                  (const Nothing)
                  Nothing
                  (const Nothing)
                  Just
                  (const Nothing)
                  (pvReference docRef)
                  `shouldEqual` Just docRef

    it "evaluates correctly a text value" $ quickCheck
      \string -> evalPrimitiveValue
        (const Nothing)
        (const Nothing)
        (const Nothing)
        (const Nothing)
        Nothing
        (const Nothing)
        (const Nothing)
        Just
        (pvText string)
        === Just string

    it "recognizes two text values as different" do
      pvText "a string" `shouldNotEqual` pvText "another string"
