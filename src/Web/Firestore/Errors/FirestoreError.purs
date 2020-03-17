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
