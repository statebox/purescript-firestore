module Test.Web.Firestore.DocumentPathSpec where

import Prelude
import Data.Array.NonEmpty (fromArray)
import Data.Maybe (isJust, isNothing)
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldSatisfy)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.DocumentPath (path)

suite :: Spec Unit
suite = do
  describe "DocumentPath" do
    it "is created correctly with an even number of sections" $ quickCheck
      \str1 str2 -> isJust (path =<< fromArray [str1, str2]) === true

    it "is not created correctly with an odd number of sections" $ quickCheck
      \str1 str2 str3 -> isNothing (path =<< fromArray [str1, str2, str3]) === true

    it "is not created correctly with an empty array of sections" do
      (path =<< fromArray []) `shouldSatisfy` isNothing
