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
import Web.Firestore (delete, deleteApp, doc, firestore, get, initializeApp, onSnapshot, set, snapshotData)
import Web.Firestore.Blob (blob)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (arrayDocument, mapArrayValue, mapDocument, primitiveArrayValue, primitiveDocument)
import Web.Firestore.Errors.InitializeError (evalInitializeError)
import Web.Firestore.GeographicalPoint (point)
import Web.Firestore.GetOptions (GetOptions(..), SourceOption(..))
import Web.Firestore.LatLon (lat, lon)
import Web.Firestore.PartialObserver (partialObserver)
import Web.Firestore.Path (pathFromString)
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
      eitherApp <- liftEffect $ initializeApp testOptions (Just "firestore-test1")
      eitherApp `shouldSatisfy` isRight

    it "initializes correctly an app without a name" do
      testOptions <- buildTestOptions
      eitherApp <- liftEffect $ initializeApp testOptions Nothing
      eitherApp `shouldSatisfy` isRight

    it "fails to initialize an app with an empty name" do
      testOptions <- buildTestOptions
      eitherApp <- liftEffect $ initializeApp testOptions (Just "")
      eitherApp # either
        (evalInitializeError
          (const $ fail "Should be a BadAppName InitializeError")
          (_ `shouldSatisfy` (const true))
          (const $ fail "Should be a BadAppName InitializeError"))
        (const $ fail "should not initialize an app with an empty name")

    it "fails app initialization if app is initialized twice" do
      testOptions <- buildTestOptions
      _ <- liftEffect $ initializeApp testOptions (Just "firestore-test2")
      eitherApp <- liftEffect $ initializeApp testOptions (Just "firestore-test2")
      eitherApp # either
        (evalInitializeError
          (_ `shouldSatisfy` (const true))
          (const $ fail "Should be a DuplicateApp InitializeError")
          (const $ fail "Should be a DuplicateApp InitializeError"))
        (const $ fail "should not initialize the same app twice")

    it "detects that one app is equal to itself" do
      testOptions <- buildTestOptions
      eitherApp <- liftEffect $ initializeApp testOptions (Just "firestore-test3")
      eitherApp # either
        (const $ fail "app initialization should have happened correctly")
        (\app -> app `shouldEqual` app)

    it "detects that two apps are different" do
      testOptions <- buildTestOptions
      eitherApp1 <- liftEffect $ initializeApp testOptions (Just "firestore-test4")
      eitherApp2 <- liftEffect $ initializeApp testOptions (Just "firestore-test5")
      eitherApp1 # either
        (const $ fail "app initialization should have happened correctly")
        (\app1 -> eitherApp2 # either
          (const $ fail "app initialization should have happened correctly")
          (\app2 -> app1 `shouldNotEqual` app2))

    it "retrieves a firestore instance" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test6")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          firestoreInstance <- liftEffect $ firestore app
          firestoreInstance `shouldSatisfy` isRight

    it "does not retrieve a firestore instance if the app gets deleted" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test7")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          deletePromise <- liftEffect $ deleteApp app
          _ <- toAff $ deletePromise
          firestoreInstance <- liftEffect $ firestore app
          firestoreInstance `shouldSatisfy` isLeft

    it "does create a document reference" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test8")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
              maybeDocRef `shouldSatisfy` isJust

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
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test9")
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

    it "sets data correctly with merge option" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test10")
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

    it "sets data correctly with mergeFields option" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test11")
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

    it "gets existing data correctly with default options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test12")
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

    it "gets existing data correctly with cache options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test13")
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

    it "gets existing data correctly with server options" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test14")
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

    it "gets data which was not set before" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test15")
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

    it "sets and gets data correctly" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test16")
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

    it "sets and gets data correctly with estimate timestamp" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test17")
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

    it "sets and gets data correctly with previous timestamp" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test18")
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

    it "deletes correctly document data" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test19")
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

    it "subscribes for document updates" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test20")
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

    it "subscribes for document updates with metadata" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test21")
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

    it "subscribes for document updates with error and complete callbacks" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test22")
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
