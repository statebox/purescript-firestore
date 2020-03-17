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
