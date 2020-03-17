module Web.Firestore.Errors.InitializeError
( FirebaseError
, InitializeError
, evalInitializeError
, fromFirebaseError
, fromString
) where

import Prelude
import Control.Alt ((<|>))
import Data.Either (Either, either)
import Data.Foldable (foldr)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String.Regex (Regex, match, regex)
import Data.String.Regex.Flags (ignoreCase)
import Data.Traversable (sequence)
import Data.Tuple.Nested (type (/\), (/\))

data InitializeError
  = DuplicateApp String
  | BadAppName String
  | Other String

evalInitializeError :: forall a. (String -> a) -> (String -> a) -> (String -> a) -> InitializeError -> a
evalInitializeError onDuplicateApp onBadAppName onOther = case _ of
  DuplicateApp s -> onDuplicateApp s
  BadAppName   s -> onBadAppName s
  Other        s -> onOther s

errorMatchers :: Either String (Array (Regex /\ (String -> InitializeError)))
errorMatchers = sequence [ (_ /\ DuplicateApp) <$> regex "^FirebaseError: Firebase: Firebase App named" ignoreCase
                         , (_ /\ BadAppName  ) <$> regex "^FirebaseError: Firebase: Illegal App name"   ignoreCase
                         ]

fromString :: String -> InitializeError
fromString s = errorMatchers # either
  (const $ Other s)
  (foldr tryMatch Nothing >>> fromMaybe (Other s))
  where
    tryMatch :: Regex /\ (String -> InitializeError) -> Maybe InitializeError -> Maybe InitializeError
    tryMatch (regex /\ constructor) previous = previous <|> trySingleMatch regex constructor s

    trySingleMatch :: Regex -> (String -> InitializeError) -> String -> Maybe InitializeError
    trySingleMatch regex constructor s' = const (constructor s') <$> match regex s'

foreign import data FirebaseError :: Type

foreign import fromFirebaseErrorImpl :: Fn2 (String -> InitializeError) FirebaseError InitializeError

fromFirebaseError :: (String -> InitializeError) -> FirebaseError -> InitializeError
fromFirebaseError = runFn2 fromFirebaseErrorImpl

instance showInitializeError :: Show InitializeError where
  show = case _ of
    DuplicateApp s -> s
    BadAppName   s -> s
    Other        s -> s

instance eqInitializeError :: Eq InitializeError where
  eq (DuplicateApp s1) (DuplicateApp s2) = eq s1 s2
  eq (Other        s1) (Other        s2) = eq s1 s2
  eq _                 _                 = false
