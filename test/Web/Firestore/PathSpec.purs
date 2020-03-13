module Test.Web.Firestore.PathSpec where

import Prelude
import Data.Maybe (isJust, isNothing)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldSatisfy)

import Web.Firestore.Path (path)

suite :: Spec Unit
suite = do
  describe "Path" do
    it "is created correctly with an even number of sections" do
      path ["foo", "bar"] `shouldSatisfy` isJust

    it "is not created correctly with an odd number of sections" do
      path ["foo", "bar", "baz"] `shouldSatisfy` isNothing
