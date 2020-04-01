{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.Errors.FirebaseError where

import Prelude
import Control.Alt ((<|>))
import Data.Either (Either, either)
import Data.Foldable (foldr)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Regex (Regex, match, regex)
import Data.String.Regex.Flags (ignoreCase)
import Data.Traversable (sequence)
import Data.Tuple.Nested (type (/\), (/\))

foreign import data FirebaseError :: Type

class FromFirebaseError a where
  patterns :: Array (String /\ (String -> a))
  fromFirebaseError :: (String -> a) -> FirebaseError -> a
  default :: String -> a

errorMatchers :: forall a. FromFirebaseError a => Either String (Array (Regex /\ (String -> a)))
errorMatchers = sequence $ (\(pattern /\ constructor) -> (_ /\ constructor) <$> regex pattern ignoreCase) <$> patterns

fromString :: forall a. FromFirebaseError a => String -> a
fromString s = errorMatchers # either
  (const $ default s)
  (foldr tryMatch Nothing >>> fromMaybe (default s))
  where
    tryMatch :: Regex /\ (String -> a) -> Maybe a -> Maybe a
    tryMatch (regex /\ constructor) previous = previous <|> trySingleMatch regex constructor s

    trySingleMatch :: Regex -> (String -> a) -> String -> Maybe a
    trySingleMatch regex constructor s' = const (constructor s') <$> match regex s'
