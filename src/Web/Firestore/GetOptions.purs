{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

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
