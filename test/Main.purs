module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import Test.Web.FirestoreSpec as Firestore
import Test.Web.Firestore.BlobSpec as Blob
import Test.Web.Firestore.OptionsSpec as Options
import Test.Web.Firestore.PathSpec as Path
import Test.Web.Firestore.PrimitiveValueSpec as PrimitiveValue
import Test.Web.Firestore.TimestampSpec as Timestamp

main :: Effect (Fiber Unit)
main = launchAff $ runSpec [consoleReporter] do
  -- Blob.suite
  -- Options.suite
  -- Path.suite
  -- PrimitiveValue.suite
  -- Timestamp.suite
  Firestore.suite
