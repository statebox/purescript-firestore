module Test.Web.Firestore.BlobSpec where

import Prelude
import Test.QuickCheck ((===))
import Test.Spec (Spec, describe, it)
import Test.Spec.QuickCheck (quickCheck)

import Web.Firestore.Blob (blob)

suite :: Spec Unit
suite = do
  describe "Blob" do
    it "encodes and decodes correctly a string" $ quickCheck
      \s -> show (blob s) === s
