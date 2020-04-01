{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.SnapshotOptions where

import Data.Argonaut (class EncodeJson, encodeJson, fromString, jsonEmptyObject, (:=), (~>))

data ServerTimestamps
  = Estimate
  | Previous
  | None

instance encodeJsonServerTimestamps :: EncodeJson ServerTimestamps where
  encodeJson = case _ of
    Estimate -> fromString "estimate"
    Previous -> fromString "previous"
    None     -> fromString "none"

data SnapshotOptions = SnapshotOptions ServerTimestamps

instance encodeJsonSnapshotOptions :: EncodeJson SnapshotOptions where
  encodeJson (SnapshotOptions serverTimestamps) = "serverTimestamps" := encodeJson serverTimestamps ~> jsonEmptyObject
