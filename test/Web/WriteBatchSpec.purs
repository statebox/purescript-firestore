{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.WriteBatchSpec where

import Prelude
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Foreign.Object (fromFoldable)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (batch, batchSet, doc, initializeApp, firestore)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (primitiveDocument)
import Web.Firestore.Path (pathFromString)
import Web.Firestore.PrimitiveValue (pvBoolean, pvNull, pvNumber, pvText)

suite :: Spec Unit
suite = do
  describe "Firestore" do
    it "creates a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch1")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              let writeBatch = batch firestoreInstance
              pure unit

    let document = DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText    "some text"))
                                              , "number"    /\ (primitiveDocument (pvNumber  273.15     ))
                                              , "bool"      /\ (primitiveDocument (pvBoolean true       ))
                                              , "null"      /\ (primitiveDocument (pvNull               ))
                                              ])

    it "sets document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch2")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  let writeBatch = batch firestoreInstance
                      _ = batchSet writeBatch docRef document Nothing
                  pure unit
