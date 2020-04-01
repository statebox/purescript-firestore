{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.Error.FirestoreError
( FirestoreError
) where

import Prelude
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Tuple.Nested ((/\))

import Web.Firestore.Errors.FirebaseError (class FromFirebaseError, FirebaseError)

data FirestoreError
  = AlreadyDeletedApp String
  | Other String

foreign import fromFirebaseErrorImpl :: Fn2 (String -> FirestoreError) FirebaseError FirestoreError

instance fromFirebaseErrorFirestoreError :: FromFirebaseError FirestoreError where
  patterns = [ ("^FirebaseError: Firebase: Firebase App named" /\ AlreadyDeletedApp  )
             ]
  fromFirebaseError = runFn2 fromFirebaseErrorImpl
  default = Other

instance showFirestoreError :: Show FirestoreError where
  show = case _ of
    AlreadyDeletedApp s -> s
    Other             s -> s
