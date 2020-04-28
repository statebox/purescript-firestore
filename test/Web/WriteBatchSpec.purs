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

import Control.Promise (toAff)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust, isJust, isNothing)
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Foreign.Object (empty, fromFoldable)
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (batch, batchCommit, batchDelete, batchSet, batchUpdate, doc, firestore, get, initializeApp, set, snapshotData)
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
        otherDocument = DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText    "some other text"))
                                                   , "number"    /\ (primitiveDocument (pvNumber  3.1415           ))
                                                   , "bool"      /\ (primitiveDocument (pvBoolean false            ))
                                                   , "null"      /\ (primitiveDocument (pvNull                     ))
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

    it "deletes document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch3")
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
                      _ = batchDelete writeBatch docRef
                  pure unit

    it "updates document on a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch4")
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
                      _ = batchUpdate writeBatch docRef document
                  pure unit

    it "commits a write batch" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch5")
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
                  let writeBatch  = batch firestoreInstance
                      writeBatch1 = batchSet writeBatch docRef document Nothing
                      writeBatch2 = batchUpdate writeBatch docRef document
                      writeBatch3 = batchDelete writeBatch docRef
                  batchCommitPromise <- liftEffect $ batchCommit writeBatch3
                  isJust batchCommitPromise `shouldEqual` true
                  toAff (unsafePartial $ fromJust batchCommitPromise)

    it "does not commit a write batch twice" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch6")
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
                  let writeBatch  = batch firestoreInstance
                      writeBatch1 = batchSet writeBatch docRef document Nothing
                      writeBatch2 = batchUpdate writeBatch docRef document
                      writeBatch3 = batchDelete writeBatch docRef
                  batchCommitPromise1 <- liftEffect $ batchCommit writeBatch3
                  isJust batchCommitPromise1 `shouldEqual` true
                  toAff (unsafePartial $ fromJust batchCommitPromise1)
                  batchCommitPromise2 <- liftEffect $ batchCommit writeBatch3
                  isNothing batchCommitPromise2 `shouldEqual` true

    it "really does things with a batch write" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test-batch7")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              -- create documents to be modified
              maybeDocRef1 <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test1")
              let docRef1 = unsafePartial $ fromJust maybeDocRef1
              maybeDocRef2 <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test2")
              let docRef2 = unsafePartial $ fromJust maybeDocRef2
              setPromise1 <- liftEffect $ set docRef1 document Nothing
              toAff setPromise1
              setPromise2 <- liftEffect $ set docRef2 document Nothing
              toAff setPromise2
              -- create write batch
              maybeDocRef3 <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test3")
              let docRef3 = unsafePartial $ fromJust maybeDocRef3
              let writeBatch  = batch firestoreInstance
                  writeBatch1 = batchSet writeBatch docRef3 document Nothing
                  writeBatch2 = batchUpdate writeBatch docRef1 otherDocument
                  writeBatch3 = batchDelete writeBatch docRef2
              -- commit write batch
              batchCommitPromise <- liftEffect $ batchCommit writeBatch3
              toAff (unsafePartial $ fromJust batchCommitPromise)
              -- check write batch had the desired effects
              getPromise1 <- liftEffect $ get docRef1 Nothing
              snapshot1 <- toAff getPromise1
              result1 <- liftEffect $ snapshotData snapshot1 Nothing
              result1 `shouldEqual` otherDocument

              getPromise2 <- liftEffect $ get docRef2 Nothing
              snapshot2 <- toAff getPromise2
              result2 <- liftEffect $ snapshotData snapshot2 Nothing
              result2 `shouldEqual` DocumentData empty

              getPromise3 <- liftEffect $ get docRef3 Nothing
              snapshot3 <- toAff getPromise3
              result3 <- liftEffect $ snapshotData snapshot3 Nothing
              result3 `shouldEqual` document
