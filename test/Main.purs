{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (Fiber, launchAff)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

import Test.Web.FirestoreCollectionSpec as FirestoreCollection
import Test.Web.FirestoreDocumentSpec as FirestoreDocument
import Test.Web.Firestore.BlobSpec as Blob
import Test.Web.Firestore.DocumentDataSpec as DocumentData
import Test.Web.Firestore.DocumentValueSpec as DocumentValue
import Test.Web.Firestore.OptionsSpec as Options
import Test.Web.Firestore.DocumentPathSpec as DocumentPath
import Test.Web.Firestore.PrimitiveValueSpec as PrimitiveValue
import Test.Web.Firestore.TimestampSpec as Timestamp

main :: Effect (Fiber Unit)
main = launchAff $ runSpec [consoleReporter] do
  Blob.suite
  DocumentData.suite
  DocumentValue.suite
  Options.suite
  DocumentPath.suite
  PrimitiveValue.suite
  Timestamp.suite
  FirestoreDocument.suite
  FirestoreCollection.suite
