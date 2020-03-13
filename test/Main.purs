module Test.Main where

import Prelude

import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import Test.Web.FirestoreSpec as Firestore
import Test.Web.Firestore.OptionsSpec as Options

main :: Effect (Fiber Unit)
main = launchAff $ runSpec [consoleReporter] do
  Options.suite
  Firestore.suite
