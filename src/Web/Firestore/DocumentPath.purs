{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.DocumentPath (DocumentPath, path, pathFromString) where

import Prelude
import Control.Bind (bindFlipped)
import Data.Array.NonEmpty (NonEmptyArray, fromArray, length)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)

-- | A non-empty slash-separated path to a document
newtype DocumentPath = DocumentPath (NonEmptyArray String)

instance showDocumentPath :: Show DocumentPath where
  show (DocumentPath sections) = intercalate "/" sections

path :: NonEmptyArray String -> Maybe DocumentPath
path sections = if mod (length sections) 2 == 0
  then Just $ DocumentPath sections
  else Nothing

pathFromString :: String -> Maybe DocumentPath
pathFromString = bindFlipped path <<< fromArray <<< split (Pattern "/")
