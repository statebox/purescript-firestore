module Web.Firestore.Errors.InitializeError
( FirebaseError
, InitializeError
, evalInitializeError
, fromFirebaseError
, fromString
) where

import Prelude
import Data.Either (either)
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Maybe (Maybe(..))
import Data.String.Regex (Regex, match, regex)
import Data.String.Regex.Flags (ignoreCase)

data InitializeError
  = DuplicateApp String
  | Other String

evalInitializeError :: forall a. (String -> a) -> (String -> a) -> InitializeError -> a
evalInitializeError onDuplicateApp onOther = case _ of
  DuplicateApp s -> onDuplicateApp s
  Other        s -> onOther s

fromString :: String -> InitializeError
fromString s = either
  (const $ Other s)
  withRegex
  (regex "^FirebaseError: Firebase: Firebase App named " ignoreCase)
  where
    withRegex :: Regex -> InitializeError
    withRegex regex = case match regex s of
      Just _  -> DuplicateApp s
      Nothing -> Other s

foreign import data FirebaseError :: Type

foreign import fromFirebaseErrorImpl :: Fn2 (String -> InitializeError) FirebaseError InitializeError

fromFirebaseError :: (String -> InitializeError) -> FirebaseError -> InitializeError
fromFirebaseError = runFn2 fromFirebaseErrorImpl

instance showInitializeError :: Show InitializeError where
  show = case _ of
    DuplicateApp s -> s
    Other        s -> s

instance eqInitializeError :: Eq InitializeError where
  eq (DuplicateApp s1) (DuplicateApp s2) = eq s1 s2
  eq (Other        s1) (Other        s2) = eq s1 s2
  eq _                 _                 = false
