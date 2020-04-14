module Test.Web.FirestoreCollectionSpec where

import Prelude hiding (add)
import Control.Promise (toAff)
import Data.Array ((:))
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust, isJust)
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Effect.Ref (modify_, new, read)
import Foreign.Object (fromFoldable)
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual, shouldSatisfy)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (add, clearCollection, collection, deleteApp, firestore, get, getCollection, initializeApp, snapshotData)
import Web.Firestore.Blob (blob)
import Web.Firestore.CollectionPath (pathFromString)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (arrayDocument, mapArrayValue, mapDocument, primitiveArrayValue, primitiveDocument)
import Web.Firestore.GeographicalPoint (point)
import Web.Firestore.GetOptions (GetOptions(..), SourceOption(..))
import Web.Firestore.LatLon (lat, lon)
import Web.Firestore.PrimitiveValue (pvBytes, pvBoolean, pvDateTime, pvGeographicalPoint, pvNull, pvNumber, pvText)
import Web.Firestore.QuerySnapshot (forEach, queryDocumentReference)
import Web.Firestore.Timestamp (microseconds, seconds, timestamp)

suite :: Spec Unit
suite = do
  describe "Firestore collection" do
    -- it "does create a collection reference" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           maybeCollectionRef `shouldSatisfy` isJust
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    let mapDoc = mapDocument (fromFoldable [ "mapText"    /\ (primitiveDocument (pvText   "some other text"))
                                           , "mapInteger" /\ (primitiveDocument (pvNumber 42.0             ))
                                           ])
        arrayMapDoc = mapArrayValue (fromFoldable [ "arrayMapNull" /\ (primitiveDocument (pvNull))
                                                  , "arrayMapBool" /\ (primitiveDocument (pvBoolean false))
                                                  ])
        ts = timestamp (seconds 1584696645.0) (microseconds 123456)
        geoPoint = point (unsafePartial $ fromJust $ lat 45.666) (unsafePartial $ fromJust $ lon 12.25)
        bytes = blob "ꘚ見꿮嬲霃椮줵"
        document1 = DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText              "some text"))
                                               , "number"    /\ (primitiveDocument (pvNumber            273.15     ))
                                               , "bool"      /\ (primitiveDocument (pvBoolean           true       ))
                                               , "null"      /\ (primitiveDocument (pvNull                         ))
                                               , "point"     /\ (primitiveDocument (pvGeographicalPoint geoPoint   ))
                                               ])
        document2 = DocumentData (fromFoldable [ "datetime"  /\ (primitiveDocument (pvDateTime          ts         ))
                                               , "map"       /\ mapDoc
                                               , "array"     /\ (arrayDocument [ primitiveArrayValue (pvNumber 273.15)
                                                                               , arrayMapDoc
                                                                               ])
                                               , "bytes"     /\ (primitiveDocument (pvBytes             bytes      ))
                                               ])

    -- it "adds documents to a collection" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               pure unit
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "gets data from a collection" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               getPromise <- liftEffect $ getCollection collectionRef Nothing
    --               querySnapshot <- toAff getPromise
    --               pure unit
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "gets data from a collection with cache options" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               getPromise <- liftEffect $ getCollection collectionRef (Just $ GetOptions Cache)
    --               querySnapshot <- toAff getPromise
    --               pure unit
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "gets data from a collection with server options" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               getPromise <- liftEffect $ getCollection collectionRef (Just $ GetOptions Server)
    --               querySnapshot <- toAff getPromise
    --               pure unit
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "gets data from an empty collection" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               getPromise <- liftEffect $ getCollection collectionRef Nothing
    --               querySnapshot <- toAff getPromise
    --               pure unit
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "cycles through the documents of a collection" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               getPromise <- liftEffect $ getCollection collectionRef Nothing
    --               querySnapshot <- toAff getPromise
    --               forEach querySnapshot (const $ pure unit)
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

    -- it "clears a collection" do
    --   testOptions <- buildTestOptions
    --   eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test")
    --   case eitherErrorApp of
    --     Left error -> fail $ show error
    --     Right app  -> do
    --       eitherFirestoreInstance <- liftEffect $ firestore app
    --       case eitherFirestoreInstance of
    --         Left error -> fail $ show error
    --         Right firestoreInstance -> do
    --           maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
    --           case maybeCollectionRef of
    --             Nothing            -> fail "invalid path"
    --             Just collectionRef -> do
    --               addPromise1 <- liftEffect $ add collectionRef document1
    --               _ <- toAff addPromise1
    --               addPromise2 <- liftEffect $ add collectionRef document2
    --               _ <- toAff addPromise2
    --               clearCollection collectionRef
    --               getPromise <- liftEffect $ getCollection collectionRef Nothing
    --               querySnapshot <- toAff getPromise
    --               forEach querySnapshot (const $ fail "no document should be present now!")
    --       deletePromise <- liftEffect $ deleteApp app
    --       toAff deletePromise

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
              maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
              case maybeCollectionRef of
                Nothing            -> fail "invalid path"
                Just collectionRef -> do
                  clearCollection collectionRef
                  docs <- liftEffect $ new []
                  addPromise1 <- liftEffect $ add collectionRef document1
                  _ <- toAff addPromise1
                  addPromise2 <- liftEffect $ add collectionRef document2
                  _ <- toAff addPromise2
                  getCollectionPromise <- liftEffect $ getCollection collectionRef Nothing
                  querySnapshot <- toAff getCollectionPromise
                  forEach querySnapshot (\queryDocumentSnapshot -> do
                    let docRef = queryDocumentReference queryDocumentSnapshot
                    getPromise <- liftEffect $ get docRef Nothing
                    docSnapshot <- toAff getPromise
                    docData <- liftEffect $ snapshotData docSnapshot Nothing
                    liftEffect $ modify_ (\l -> docData : l) docs)
                  docsData <- liftEffect $ read docs
                  docsData `shouldEqual` [document1, document2]
          deletePromise <- liftEffect $ deleteApp app
          toAff deletePromise