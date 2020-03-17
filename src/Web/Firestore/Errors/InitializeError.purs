module Web.Firestore.Errors.InitializeError
( InitializeError
, evalInitializeError
) where

import Prelude
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Tuple.Nested ((/\))

import Web.Firestore.Errors.FirebaseError (class FromFirebaseError, FirebaseError)

data InitializeError
  = DuplicateApp String
  | BadAppName String
  | Other String

evalInitializeError :: forall a. (String -> a) -> (String -> a) -> (String -> a) -> InitializeError -> a
evalInitializeError onDuplicateApp onBadAppName onOther = case _ of
  DuplicateApp s -> onDuplicateApp s
  BadAppName   s -> onBadAppName s
  Other        s -> onOther s

foreign import fromFirebaseErrorImpl :: Fn2 (String -> InitializeError) FirebaseError InitializeError

instance fromFirebaseErrorInitializeError :: FromFirebaseError InitializeError where
  patterns = [ ("^FirebaseError: Firebase: Firebase App named" /\ DuplicateApp)
             , ("^FirebaseError: Firebase: Illegal App name"   /\ BadAppName  )
             ]
  fromFirebaseError = runFn2 fromFirebaseErrorImpl
  default = Other

instance showInitializeError :: Show InitializeError where
  show = case _ of
    DuplicateApp s -> s
    BadAppName   s -> s
    Other        s -> s

instance eqInitializeError :: Eq InitializeError where
  eq (DuplicateApp s1) (DuplicateApp s2) = eq s1 s2
  eq (Other        s1) (Other        s2) = eq s1 s2
  eq _                 _                 = false
