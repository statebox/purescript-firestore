module Test.Web.Firestore.OptionsUtils where

import Prelude
import Control.Monad.Error.Class (throwError)
import Data.Lens as Lens
import Data.Maybe (Maybe(..))
import Dotenv (loadFile) as Dotenv
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Node.Process (lookupEnv)

import Web.Firestore.Options (Options, apiKey, appId, authDomain, databaseUrl, messagingSenderId, options, storageBucket)

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
