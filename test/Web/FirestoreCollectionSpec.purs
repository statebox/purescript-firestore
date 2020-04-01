module Test.Web.FirestoreCollectionSpec where

import Prelude
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), isJust)
import Data.Traversable (sequence)
import Effect.Class (liftEffect)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (fail, shouldSatisfy)

import Test.Web.Firestore.OptionsUtils (buildTestOptions)
import Web.Firestore (collection, firestore, initializeApp)
import Web.Firestore.CollectionPath (pathFromString)

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
              maybeDocRef <- liftEffect $ sequence $ collection firestoreInstance <$> (pathFromString "collection")
              maybeDocRef `shouldSatisfy` isJust