module Test.Web.Firestore.PathSpec where

import Prelude
import Data.Maybe (isJust, isNothing)
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.Path (path)

suite :: Spec Unit
suite = do
  describe "Path" do
    it "is created correctly with an even number of sections" $ quickCheck
      \str1 str2 -> isJust (path [str1, str2]) === true

    it "is not created correctly with an odd number of sections" $ quickCheck
      \str1 str2 str3 -> isNothing (path [str1, str2, str3]) === true
