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
