{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore
( App
, DocumentSnapshot
, Firestore
, WriteBatch
, batch
, batchSet
, delete
, deleteApp
, doc
, firestore
, get
, initializeApp
, onSnapshot
, set
, snapshotData
, update
) where

import Prelude
import Control.Promise (Promise)
import Data.Argonaut (Json, encodeJson)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, runFn1, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.Profunctor.Choice ((+++))
import Effect (Effect)

import Web.Firestore.DocumentData (DocumentData)
import Web.Firestore.DocumentReference (DocumentReference)
import Web.Firestore.Error.FirestoreError (FirestoreError)
import Web.Firestore.Errors.FirebaseError (FirebaseError, fromFirebaseError, fromString)
import Web.Firestore.Errors.InitializeError (InitializeError)
import Web.Firestore.GetOptions (GetOptions)
import Web.Firestore.Options (Options)
import Web.Firestore.PartialObserver (PartialObserver)
import Web.Firestore.Path (Path)
import Web.Firestore.SetOptions (SetOptions)
import Web.Firestore.SnapshotListenOptions (SnapshotListenOptions)
import Web.Firestore.SnapshotOptions (SnapshotOptions)

foreign import data App :: Type

foreign import showAppImpl :: Fn1 App String

foreign import eqAppImpl :: Fn2 App App Boolean

instance showApp :: Show App where
  show = runFn1 showAppImpl

instance eqApp :: Eq App where
  eq = runFn2 eqAppImpl

foreign import initializeAppImpl :: Fn4
  (String -> Either String App)
  (App -> Either String App)
  Json
  (Nullable String)
  (Effect (Either FirebaseError App))

initializeApp :: Options -> Maybe String -> Effect (Either InitializeError App)
initializeApp options name = (fromFirebaseError fromString +++ identity) <$>
  runFn4 initializeAppImpl Left Right (encodeJson options) (toNullable name)

foreign import deleteAppImpl :: Fn1 App (Effect (Promise Unit))

deleteApp :: App -> Effect (Promise Unit)
deleteApp = runFn1 deleteAppImpl

foreign import data Firestore :: Type

foreign import showFirestoreImpl :: Fn1 Firestore String

instance showFirestore :: Show Firestore where
  show = runFn1 showFirestoreImpl

foreign import firestoreImpl :: Fn3
  (FirebaseError -> Either FirebaseError Firestore)
  (Firestore -> Either FirebaseError Firestore)
  App
  (Effect (Either FirebaseError Firestore))

firestore :: App -> Effect (Either FirestoreError Firestore)
firestore app = (fromFirebaseError fromString +++ identity) <$> runFn3 firestoreImpl Left Right app

foreign import docImpl :: Fn2 Firestore String (Effect (DocumentReference DocumentData))

doc :: Firestore -> Path -> Effect (DocumentReference DocumentData)
doc fs path = runFn2 docImpl fs (show path)

foreign import setImpl ::Fn3 (DocumentReference DocumentData) DocumentData (Nullable SetOptions) (Effect (Promise Unit))

set :: DocumentReference DocumentData -> DocumentData -> Maybe SetOptions -> Effect (Promise Unit)
set docRef docData options = runFn3 setImpl docRef docData (toNullable options)

foreign import deleteImpl :: forall a. Fn1 (DocumentReference a) (Effect (Promise Unit))

delete :: forall a. DocumentReference a -> Effect (Promise Unit)
delete = runFn1 deleteImpl

foreign import data DocumentSnapshot :: Type -> Type

foreign import getImpl :: forall a. Fn2 (DocumentReference a) (Nullable Json) (Effect (Promise (DocumentSnapshot a)))

get :: forall a. DocumentReference a -> Maybe GetOptions -> Effect (Promise (DocumentSnapshot a))
get docRef options = (runFn2 getImpl) docRef (toNullable $ encodeJson <$> options)

foreign import dataImpl :: Fn2 (DocumentSnapshot DocumentData) (Nullable Json) (Effect DocumentData)

snapshotData :: DocumentSnapshot DocumentData -> Maybe SnapshotOptions -> Effect DocumentData
snapshotData docSnapshot options = runFn2 dataImpl docSnapshot (toNullable $ encodeJson <$> options)

foreign import onSnapshotImpl :: Fn3
  (DocumentReference DocumentData)
  (PartialObserver (DocumentSnapshot DocumentData))
  (Nullable SnapshotListenOptions)
  (Effect (Unit -> Effect Unit))

onSnapshot
  :: DocumentReference DocumentData
  -> PartialObserver (DocumentSnapshot DocumentData)
  -> Maybe SnapshotListenOptions
  -> Effect (Unit -> Effect Unit)
onSnapshot docRef observer options = runFn3 onSnapshotImpl docRef observer (toNullable options)

foreign import updateImpl :: forall a. Fn2 (DocumentReference a) DocumentData (Effect (Promise Unit))

update :: forall a. DocumentReference a -> DocumentData -> Effect (Promise Unit)
update = runFn2 updateImpl

-- Write batch

foreign import data WriteBatch :: Type

foreign import batchImpl :: Fn1 Firestore WriteBatch

batch :: Firestore -> WriteBatch
batch = runFn1 batchImpl

foreign import batchSetImpl :: forall a. Fn4 WriteBatch (DocumentReference a) a (Nullable SetOptions) WriteBatch

batchSet :: forall a. WriteBatch -> DocumentReference a -> a -> Maybe SetOptions -> WriteBatch
batchSet writeBatch docRef docData options = runFn4 batchSetImpl writeBatch docRef docData (toNullable options)
