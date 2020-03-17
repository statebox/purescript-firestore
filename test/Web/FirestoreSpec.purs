module Test.Web.FirestoreSpec where

import Prelude
import Control.Monad.Error.Class (throwError)
import Control.Promise (toAff)
import Data.Either (Either(..), either, isRight)
import Data.Lens as Lens
import Data.Maybe (Maybe(..))
import Data.Traversable (sequence)
import Data.Tuple.Nested ((/\))
import Dotenv (loadFile) as Dotenv
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Foreign.Object (fromFoldable)
import Node.Process (lookupEnv)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldEqual, shouldNotEqual, shouldSatisfy)

import Web.Firestore (doc, firestore, get, initializeApp, set, snapshotData)
import Web.Firestore.DocumentData (DocumentData(..))
import Web.Firestore.DocumentValue (DocumentValue(..))
import Web.Firestore.Errors.InitializeError (evalInitializeError)
import Web.Firestore.Options (Options, apiKey, appId, authDomain, databaseUrl, messagingSenderId, options, storageBucket)
import Web.Firestore.Path (pathFromString)
import Web.Firestore.PrimitiveValue (PrimitiveValue(..))
import Web.Firestore.SetOptions (mergeFieldsOption, stringMergeField, fieldPathMergeField)

buildTestOptions :: Aff Options
buildTestOptions = do
  _ <- Dotenv.loadFile
  firestoreProjectId         <- liftEffect $ lookupEnv "FIRESTORE_PROJECT_ID"
  firestoreApiKey            <- liftEffect $ lookupEnv "FIRESTORE_API_KEY"
  firestoreAppId             <- liftEffect $ lookupEnv "FIRESTORE_APP_ID"
  firestoreAuthDomain        <- liftEffect $ lookupEnv "FIRESTORE_AUTH_DOMAIN"
  firestoreDatabaseUrl       <- liftEffect $ lookupEnv "FIRESTORE_DATABASE_URL"
  firestoreMessagingSenderId <- liftEffect $ lookupEnv "FIRESTORE_MESSAGING_SENDER_ID"
  firestoreStorageBucket     <- liftEffect $ lookupEnv "FIRESTORE_STORAGE_BUCKET"
  let maybeOptions = firestoreProjectId <#> (\projectId -> options projectId
                                             # Lens.set apiKey            firestoreApiKey
                                             # Lens.set appId             firestoreAppId
                                             # Lens.set authDomain        firestoreAuthDomain
                                             # Lens.set databaseUrl       firestoreDatabaseUrl
                                             # Lens.set messagingSenderId firestoreMessagingSenderId
                                             # Lens.set storageBucket     firestoreStorageBucket)
  case maybeOptions of
    Nothing      -> throwError (error "invalid configuration options")
    Just options -> pure options

suite :: Spec Unit
suite = do
  describe "Firestore" do
    it "initializes correctly an app with a name" do
      testOptions <- buildTestOptions
      eitherApp <- liftEffect $ initializeApp testOptions (Just "firestore-test1")
      eitherApp `shouldSatisfy` isRight

    it "initializes correctly an app without a name" do
      testOptions <- buildTestOptions
      eitherApp <- liftEffect $ initializeApp testOptions Nothing
      eitherApp `shouldSatisfy` isRight

    it "fails app initialization if app is initialized twice" do
      testOptions <- buildTestOptions
      _ <- liftEffect $ initializeApp testOptions (Just "firestore-test2")
      eitherApp <- liftEffect $ initializeApp testOptions (Just "firestore-test2")
      eitherApp # either
        (evalInitializeError
          (_ `shouldSatisfy` (const true))
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

    it "sets and gets data correctly" do
      testOptions <- buildTestOptions
      eitherErrorApp <- liftEffect $ initializeApp testOptions (Just "firestore-test6")
      case eitherErrorApp of
        Left error -> fail $ show error
        Right app  -> do
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
