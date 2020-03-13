module Test.Web.Firestore.OptionsSpec where

import Prelude
import Data.Lens as Lens
import Data.Maybe (Maybe(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)

import Web.Firestore.Options (Options(..), apiKey, appId, authDomain, databaseUrl, measurementId, messagingSenderId, options, storageBucket)

suite :: Spec Unit
suite = do
  describe "Options" do
    it "is created correctly using optics" do
      let oOptions = options "firestore-test-270209"
                   # Lens.set apiKey            (Just "AIzaSyBDH92I_Qiv_GHbIOA0MddiOKZpwDaMNoY")
                   # Lens.set appId             (Just "1:490707848264:web:92683957e61378c9a21c7d")
                   # Lens.set authDomain        (Just "firestore-test-270209.firebaseapp.com")
                   # Lens.set databaseUrl       (Just "https://firestore-test-270209.firebaseio.com")
                   # Lens.set measurementId     (Just "something")
                   # Lens.set messagingSenderId (Just "490707848264")
                   # Lens.set storageBucket     (Just "firestore-test-270209.appspot.com")
          rOptions = Options { appId : Just "1:490707848264:web:92683957e61378c9a21c7d"
                             , apiKey : Just "AIzaSyBDH92I_Qiv_GHbIOA0MddiOKZpwDaMNoY"
                             , authDomain : Just "firestore-test-270209.firebaseapp.com"
                             , databaseUrl : Just "https://firestore-test-270209.firebaseio.com"
                             , measurementId : Just "something"
                             , messagingSenderId : Just "490707848264"
                             , projectId : "firestore-test-270209"
                             , storageBucket : Just "firestore-test-270209.appspot.com"}
      oOptions `shouldEqual` rOptions
