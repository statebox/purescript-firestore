module Test.Web.Firestore.OptionsSpec where

import Prelude
import Data.Lens as Lens
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.Options (Options(..), apiKey, appId, authDomain, databaseUrl, measurementId, messagingSenderId, options, storageBucket)

suite :: Spec Unit
suite = do
  describe "Options" do
    it "is created correctly using optics" $ quickCheck
      \fsProjectId fsApiKey fsAppId fsAuthDomain fsDatabaseUrl fsMeasurementId fsMessagingSenderId fsStorageBucket ->
        let oOptions = options fsProjectId
                     # Lens.set apiKey            fsApiKey
                     # Lens.set appId             fsAppId
                     # Lens.set authDomain        fsAuthDomain
                     # Lens.set databaseUrl       fsDatabaseUrl
                     # Lens.set measurementId     fsMeasurementId
                     # Lens.set messagingSenderId fsMessagingSenderId
                     # Lens.set storageBucket     fsStorageBucket
            rOptions = Options { appId : fsAppId
                               , apiKey : fsApiKey
                               , authDomain : fsAuthDomain
                               , databaseUrl : fsDatabaseUrl
                               , measurementId : fsMeasurementId
                               , messagingSenderId : fsMessagingSenderId
                               , projectId : fsProjectId
                               , storageBucket : fsStorageBucket
                               }
        in oOptions === rOptions
