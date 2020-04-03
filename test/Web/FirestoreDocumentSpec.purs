{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Web.FirestoreDocumentSpec where

import Prelude
import Control.Promise (toAff)
import Data.Either (Either(..), either, isLeft, isRight)
import Data.Maybe (Maybe(..), fromJust, isJust)
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Ref (new, read, write)
import Foreign.Object (empty, fromFoldable)
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual, shouldNotEqual, shouldSatisfy)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (delete, deleteApp, doc, docCollection, firestore, get, initializeApp, onSnapshot, set, snapshotData, update)
import Web.Firestore.Blob (blob)
import Web.Firestore.CollectionPath (pathFromString) as Collection
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentPath (pathFromString)
import Web.Firestore.DocumentValue (arrayDocument, mapArrayValue, mapDocument, primitiveArrayValue, primitiveDocument)
import Web.Firestore.Errors.InitializeError (evalInitializeError)
import Web.Firestore.GeographicalPoint (point)
import Web.Firestore.GetOptions (GetOptions(..), SourceOption(..))
import Web.Firestore.LatLon (lat, lon)
import Web.Firestore.PartialObserver (partialObserver)
import Web.Firestore.PrimitiveValue (pvBytes, pvBoolean, pvDateTime, pvGeographicalPoint, pvNull, pvNumber, pvReference, pvText)
import Web.Firestore.SetOptions (mergeFieldsOption, mergeOption, stringMergeField, fieldPathMergeField)
import Web.Firestore.SnapshotListenOptions (SnapshotListenOptions(..))
import Web.Firestore.SnapshotOptions (ServerTimestamps(..), SnapshotOptions(..))
import Web.Firestore.Timestamp (microseconds, seconds, timestamp)

suite :: Spec Unit
suite = do
  describe "Firestore document" do
    it "initializes correctly an app with a name" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      eitherErrorApp `shouldSatisfy` isRight
      case eitherErrorApp of
        Left error -> pure unit
        Right app  -> do
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "initializes correctly an app without a name" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions Nothing
      eitherErrorApp `shouldSatisfy` isRight
      case eitherErrorApp of
        Left error -> pure unit
        Right app  -> do
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "fails to initialize an app with an empty name" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "")
      eitherErrorApp # either
        (evalInitializeError
          (const $ fail "Should be a BadAppName InitializeError")
          (_ `shouldSatisfy` (const true))
          (const $ fail "Should be a BadAppName InitializeError"))
        (\app  -> do
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise
          fail "should not initialize an app with an empty name")

    it "fails app initialization if app is initialized twice" do
      testOptions <- buildTestOptions
      eitherErrorApp1 <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      eitherErrorApp2 <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      eitherErrorApp2 # either
        (evalInitializeError
          (\error -> do
            either
              (const $ pure unit)
              (\app1 -> do
                deletePromise <- liftEffect $ deleteApp app1
                toAff deletePromise)
              eitherErrorApp1
            error `shouldSatisfy` (const true))
          (\error -> do
            either
              (const $ pure unit)
              (\app1 -> do
                deletePromise <- liftEffect $ deleteApp app1
                toAff deletePromise)
              eitherErrorApp1
            fail "Should be a DuplicateApp InitializeError")
          (\error -> do
            either
              (const $ pure unit)
              (\app1 -> do
                deletePromise <- liftEffect $ deleteApp app1
                toAff deletePromise)
              eitherErrorApp1
            fail "Should be a DuplicateApp InitializeError"))
        (\app2 -> do
          deletePromise <- liftEffect $ deleteApp app2
          toAff deletePromise
          fail "should not initialize the same app twice")

    it "detects that one app is equal to itself" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      eitherErrorApp # either
        (const $ fail "app initialization should have happened correctly")
        (\app -> do
          app `shouldEqual` app
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise)

    it "detects that two apps are different" do
      testOptions <- buildTestOptions
      eitherErrorApp1 <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      eitherErrorApp2 <- liftEffect $ initializeApp testOptions (Just "firestore-test1")
      eitherErrorApp1 # either
        (const $ fail "app initialization should have happened correctly")
        (\app1 -> eitherErrorApp2 # either
          (const $ do
            deletePromise1 <- liftEffect $ deleteApp app1
            toAff deletePromise1
            fail "app initialization should have happened correctly")
          (\app2 -> do
            app1 `shouldNotEqual` app2
            deletePromise1 <- liftEffect $ deleteApp app1
            toAff deletePromise1
            deletePromise2 <- liftEffect $ deleteApp app2
            toAff deletePromise2))

    it "retrieves a firestore instance" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          firestoreInstance <- liftEffect $ firestore app
          firestoreInstance `shouldSatisfy` isRight
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "does not retrieve a firestore instance if the app gets deleted" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise
          firestoreInstance <- liftEffect $ firestore app
          firestoreInstance `shouldSatisfy` isLeft

    it "does create a document reference" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              maybeDocRef `shouldSatisfy` isJust
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    let mapDoc = mapDocument (fromFoldable [ "mapText"    /\ (primitiveDocument (pvText   "some other text"))
                                           , "mapInteger" /\ (primitiveDocument (pvNumber 42.0             ))
                                           ])
        arrayMapDoc = mapArrayValue (fromFoldable [ "arrayMapNull" /\ (primitiveDocument (pvNull))
                                                  , "arrayMapBool" /\ (primitiveDocument (pvBoolean false))
                                                  ])
        ts = timestamp (seconds 1584696645.0) (microseconds 123456)
        geoPoint = point (unsafePartial $ fromJust $ lat 45.666) (unsafePartial $ fromJust $ lon 12.25)
        bytes = blob "ꘚ見꿮嬲霃椮줵"
        document = \ref -> DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText              "some text"))
                                                      , "number"    /\ (primitiveDocument (pvNumber            273.15     ))
                                                      , "bool"      /\ (primitiveDocument (pvBoolean           true       ))
                                                      , "null"      /\ (primitiveDocument (pvNull                         ))
                                                      , "point"     /\ (primitiveDocument (pvGeographicalPoint geoPoint   ))
                                                      , "datetime"  /\ (primitiveDocument (pvDateTime          ts         ))
                                                      , "map"       /\ mapDoc
                                                      , "array"     /\ (arrayDocument [ primitiveArrayValue (pvNumber 273.15)
                                                                                      , arrayMapDoc
                                                                                      ])
                                                      , "reference" /\ (primitiveDocument (pvReference         ref        ))
                                                      , "bytes"     /\ (primitiveDocument (pvBytes             bytes      ))
                                                      ])

    it "sets data correctly with no option" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  toAff setPromise
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "sets data correctly with merge option" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc (Just $ mergeOption true)
                  toAff setPromise
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "sets data correctly with mergeFields option" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc (Just $ mergeFieldsOption [ stringMergeField "text"
                                                                                      , fieldPathMergeField ["number"]
                                                                                      ])
                  toAff setPromise
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "gets existing data correctly with default options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef Nothing
                  toAff setPromise
                  snapshot <- toAff getPromise
                  pure unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "gets existing data correctly with cache options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef (Just $ GetOptions Cache)
                  toAff setPromise
                  snapshot <- toAff getPromise
                  pure unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "gets existing data correctly with server options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef (Just $ GetOptions Server)
                  toAff setPromise
                  snapshot <- toAff getPromise
                  pure unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "gets data which was not set before" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/other-test")
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  getPromise <- liftEffect $ get docRef (Just $ GetOptions Server)
                  snapshot <- toAff getPromise
                  pure unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "sets and gets data correctly" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef Nothing
                  toAff setPromise
                  snapshot <- toAff getPromise
                  result <- liftEffect $ snapshotData snapshot Nothing

                  result `shouldEqual` doc
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "sets and gets data correctly with estimate timestamp" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef Nothing
                  toAff setPromise
                  snapshot <- toAff getPromise
                  result <- liftEffect $ snapshotData snapshot (Just $ SnapshotOptions Estimate)

                  result `shouldEqual` doc
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "sets and gets data correctly with previous timestamp" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef Nothing
                  toAff setPromise
                  snapshot <- toAff getPromise
                  result <- liftEffect $ snapshotData snapshot (Just $ SnapshotOptions Previous)

                  result `shouldEqual` doc
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "deletes correctly document data" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  getPromise <- liftEffect $ get docRef Nothing
                  deletePromise <- liftEffect $ delete docRef
                  toAff setPromise
                  toAff deletePromise
                  snapshot <- toAff getPromise
                  result <- liftEffect $ snapshotData snapshot Nothing

                  result `shouldEqual` DocumentData empty
          deleteAppPromise <- liftEffect $ deleteApp app
          toAff deleteAppPromise

    it "subscribes for document updates" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  docMaybeRef <- liftEffect $ new Nothing
                  let observer = partialObserver
                        (\snapshot -> do
                          newDoc <- liftEffect $ snapshotData snapshot Nothing
                          write (Just newDoc) docMaybeRef)
                        Nothing
                        Nothing
                      doc = document docRef
                  unsubscribe <- liftEffect $ onSnapshot docRef observer Nothing
                  setPromise <- liftEffect $ set docRef doc Nothing
                  toAff setPromise
                  res <- liftEffect $ read docMaybeRef
                  res `shouldSatisfy` isJust
                  liftEffect $ unsubscribe unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "subscribes for document updates with metadata" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  docMaybeRef <- liftEffect $ new Nothing
                  let observer = partialObserver
                        (\snapshot -> do
                          newDoc <- liftEffect $ snapshotData snapshot Nothing
                          write (Just newDoc) docMaybeRef)
                        Nothing
                        Nothing
                      doc = document docRef
                  unsubscribe <- liftEffect $
                    onSnapshot docRef observer (Just $ SnapshotListenOptions {includeMetadataChanges: true})
                  setPromise <- liftEffect $ set docRef doc Nothing
                  toAff setPromise
                  res <- liftEffect $ read docMaybeRef
                  res `shouldSatisfy` isJust
                  liftEffect $ unsubscribe unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "subscribes for document updates with error and complete callbacks" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  docMaybeRef <- liftEffect $ new Nothing
                  let observer = partialObserver
                        (\snapshot -> do
                          newDoc <- liftEffect $ snapshotData snapshot Nothing
                          write (Just newDoc) docMaybeRef)
                        (Just $ fail <<< show)
                        (Just $ const (fail "completion callback is not executed"))
                      doc = document docRef
                  unsubscribe <- liftEffect $
                    onSnapshot docRef observer (Just $ SnapshotListenOptions {includeMetadataChanges: true})
                  setPromise <- liftEffect $ set docRef doc Nothing
                  toAff setPromise
                  res <- liftEffect $ read docMaybeRef
                  res `shouldSatisfy` isJust
                  liftEffect $ unsubscribe unit
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "updates a document" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  updatePromise <- liftEffect $ update docRef doc
                  toAff updatePromise
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "updates a document with new data" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
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
                  let doc = document docRef
                  setPromise <- liftEffect $ set docRef doc Nothing
                  toAff setPromise
                  let updateData = DocumentData (fromFoldable [ "text" /\ (primitiveDocument (pvText "some other text"))])
                  updatePromise <- liftEffect $ update docRef updateData
                  toAff updatePromise
                  getPromise <- liftEffect $ get docRef Nothing
                  snapshot <- toAff getPromise
                  result <- liftEffect $ snapshotData snapshot Nothing
                  let newDoc = DocumentData
                                (fromFoldable [ "text"      /\ (primitiveDocument (pvText              "some other text"))
                                              , "number"    /\ (primitiveDocument (pvNumber            273.15     ))
                                              , "bool"      /\ (primitiveDocument (pvBoolean           true       ))
                                              , "null"      /\ (primitiveDocument (pvNull                         ))
                                              , "point"     /\ (primitiveDocument (pvGeographicalPoint geoPoint   ))
                                              , "datetime"  /\ (primitiveDocument (pvDateTime          ts         ))
                                              , "map"       /\ mapDoc
                                              , "array"     /\ (arrayDocument [ primitiveArrayValue (pvNumber 273.15)
                                                                              , arrayMapDoc
                                                                              ])
                                              , "reference" /\ (primitiveDocument (pvReference         docRef     ))
                                              , "bytes"     /\ (primitiveDocument (pvBytes             bytes      ))
                                              ])
                  result `shouldEqual` newDoc
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise

    it "retrieves a collection starting from a document" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> pathFromString "collection/test"
              case maybeDocRef of
                Nothing     -> fail "invalid path"
                Just docRef -> do
                  maybeCollectionRef <- liftEffect $ sequence $ docCollection docRef <$> Collection.pathFromString "subcollection"
                  maybeCollectionRef `shouldSatisfy` isJust
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise
