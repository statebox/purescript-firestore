module Web.Firestore.GetOptions where

import Data.Argonaut (class EncodeJson, encodeJson, fromString, jsonEmptyObject, (:=), (~>))

data SourceOption
  = Default
  | Server
  | Cache

instance encodeJsonSourceOption :: EncodeJson SourceOption where
  encodeJson = case _ of
    Default -> fromString "default"
    Server  -> fromString "server"
    Cache   -> fromString "cache"

newtype GetOptions = GetOptions SourceOption

instance encodeJsonGetOptions :: EncodeJson GetOptions where
  encodeJson (GetOptions so) = "source" := encodeJson so ~> jsonEmptyObject
