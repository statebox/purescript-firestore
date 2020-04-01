{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

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
