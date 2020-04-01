module Test.Web.FirestoreCollectionSpec where

import Prelude hiding (add)
import Control.Promise (toAff)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust, isJust)
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Effect.Class (liftEffect)
import Foreign.Object (fromFoldable)
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldSatisfy)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (add, collection, firestore, initializeApp)
import Web.Firestore.Blob (blob)
import Web.Firestore.CollectionPath (pathFromString)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (arrayDocument, mapArrayValue, mapDocument, primitiveArrayValue, primitiveDocument)
import Web.Firestore.GeographicalPoint (point)
import Web.Firestore.LatLon (lat, lon)
import Web.Firestore.PrimitiveValue (pvBytes, pvBoolean, pvDateTime, pvGeographicalPoint, pvNull, pvNumber, pvText)
import Web.Firestore.Timestamp (microseconds, seconds, timestamp)

suite :: Spec Unit
suite = do
  describe "Firestore collection" do
    it "does create a collection reference" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-collection-test")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
          eitherFirestoreInstance <- liftEffect $ firestore app
          case eitherFirestoreInstance of
            Left error -> fail $ show error
            Right firestoreInstance -> do
              maybeCollectionRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
              maybeCollectionRef `shouldSatisfy` isJust

    let mapDoc = mapDocument (fromFoldable [ "mapText"    /\ (primitiveDocument (pvText   "some other text"))
                                           , "mapInteger" /\ (primitiveDocument (pvNumber 42.0             ))
                                           ])
        arrayMapDoc = mapArrayValue (fromFoldable [ "arrayMapNull" /\ (primitiveDocument (pvNull))
                                                  , "arrayMapBool" /\ (primitiveDocument (pvBoolean false))
                                                  ])
        ts = timestamp (seconds 1584696645.0) (microseconds 123456)
        geoPoint = point (unsafePartial $ fromJust $ lat 45.666) (unsafePartial $ fromJust $ lon 12.25)
        bytes = blob "ꘚ見꿮嬲霃椮줵"
        document = DocumentData (fromFoldable [ "text"      /\ (primitiveDocument (pvText              "some text"))
                                              , "number"    /\ (primitiveDocument (pvNumber            273.15     ))
                                              , "bool"      /\ (primitiveDocument (pvBoolean           true       ))
                                              , "null"      /\ (primitiveDocument (pvNull                         ))
                                              , "point"     /\ (primitiveDocument (pvGeographicalPoint geoPoint   ))
                                              , "datetime"  /\ (primitiveDocument (pvDateTime          ts         ))
                                              , "map"       /\ mapDoc
                                              , "array"     /\ (arrayDocument [ primitiveArrayValue (pvNumber 273.15)
                                                                              , arrayMapDoc
                                                                              ])
                                              , "bytes"     /\ (primitiveDocument (pvBytes             bytes      ))
                                              ])

    it "adds documents to a collection" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-collection-test-1")
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
                  addPromise <- liftEffect $ add collectionRef document
                  _ <- toAff addPromise
                  pure unit
