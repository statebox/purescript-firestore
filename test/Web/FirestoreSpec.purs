module Test.Web.FirestoreSpec where

import Prelude
import Control.Promise (toAff)
import Data.Lens as Lens
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Dotenv (loadFile) as Dotenv
import Effect.Class (liftEffect)
import Foreign.Object (fromFoldable)
import Node.Process (lookupEnv)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual)

import Web.Firestore (doc, firestore, get, initializeApp, set, snapshotData)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (DocumentValue(..))
import Web.Firestore.Options (apiKey, appId, authDomain, databaseUrl, messagingSenderId, options, storageBucket)
import Web.Firestore.Path (pathFromString)
import Web.Firestore.PrimitiveValue (PrimitiveValue(..))
import Web.Firestore.SetOptions (mergeFieldsOption, stringMergeField, fieldPathMergeField)

suite :: Spec Unit
suite = do
  describe "Firestore" do
    it "sets and gets data correctly" do
      _ <- Dotenv.loadFile
      firestoreProjectId         <- liftEffect $ lookupEnv "FIRESTORE_PROJECT_ID"
      firestoreApiKey            <- liftEffect $ lookupEnv "FIRESTORE_API_KEY"
      firestoreAppId             <- liftEffect $ lookupEnv "FIRESTORE_APP_ID"
      firestoreAuthDomain        <- liftEffect $ lookupEnv "FIRESTORE_AUTH_DOMAIN"
      firestoreDatabaseUrl       <- liftEffect $ lookupEnv "FIRESTORE_DATABASE_URL"
      firestoreMessagingSenderId <- liftEffect $ lookupEnv "FIRESTORE_MESSAGING_SENDER_ID"
      firestoreStorageBucket     <- liftEffect $ lookupEnv "FIRESTORE_STORAGE_BUCKET"
      case firestoreProjectId of
        Nothing        -> fail "invalid project id"
        Just projectId -> do
          let fsOptions = options projectId
                        # Lens.set apiKey            firestoreApiKey
                        # Lens.set appId             firestoreAppId
                        # Lens.set authDomain        firestoreAuthDomain
                        # Lens.set databaseUrl       firestoreDatabaseUrl
                        # Lens.set messagingSenderId firestoreMessagingSenderId
                        # Lens.set storageBucket     firestoreStorageBucket
          app <- liftEffect $ initializeApp fsOptions (Just "firestore-test")
          firestoreInstance <- liftEffect $ firestore app
          maybeDocRef <- liftEffect $ sequence $ doc firestoreInstance <$> (pathFromString "collection/test")
          case maybeDocRef of
            Nothing                -> fail "invalid path"
            Just docRef ->
              let doc = DocumentData (fromFoldable [ "text"    /\ (PrimitiveDocument (PVText    "some text"))
                                                        , "integer" /\ (PrimitiveDocument (PVInteger 42         ))
                                                        , "float"   /\ (PrimitiveDocument (PVFloat   273.15     ))
                                                        , "bool"    /\ (PrimitiveDocument (PVBoolean true       ))])
              in do
                setPromise <- liftEffect $ set docRef doc (Just $ mergeFieldsOption [ stringMergeField "text"
                                                                                    , fieldPathMergeField ["float"]
                                                                                    ])
                getPromise <- liftEffect $ get docRef Nothing
                toAff setPromise
                snapshot <- toAff getPromise
                result <- liftEffect $ snapshotData snapshot Nothing

                result `shouldEqual` Just doc
