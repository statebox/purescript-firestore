module Web.Firestore.GetOptions where

import Data.Argonaut (class EncodeJson, encodeJson, fromString)

data SourceOption
  = Default
  | Server
  | Cache

instance encodeJsonSourceOption :: EncodeJson SourceOption where
  encodeJson = case _ of
    Default -> fromString "default"
    Server  -> fromString "Server"
    Cache   -> fromString "Cache"

newtype GetOptions = GetOptions SourceOption

instance encodeJsonGetOptions :: EncodeJson GetOptions where
  encodeJson (GetOptions so) = encodeJson so
