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
, add
, clearCollection
, collection
, delete
, deleteApp
, doc
, docCollection
, firestore
, get
, getCollection
, initializeApp
, onSnapshot
, set
, snapshotData
, update
) where

import Prelude
import Control.Promise (Promise, toAff)
import Data.Argonaut (Json, encodeJson)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, runFn1, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)
import Data.Profunctor.Choice ((+++))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)

import Web.Firestore.CollectionPath (CollectionPath)
import Web.Firestore.CollectionReference (CollectionReference)
import Web.Firestore.DocumentData (DocumentData)
import Web.Firestore.DocumentPath (DocumentPath)
import Web.Firestore.DocumentReference (DocumentReference)
import Web.Firestore.Error.FirestoreError (FirestoreError)
import Web.Firestore.Errors.FirebaseError (FirebaseError, fromFirebaseError, fromString)
import Web.Firestore.Errors.InitializeError (InitializeError)
import Web.Firestore.GetOptions (GetOptions)
import Web.Firestore.Options (Options)
import Web.Firestore.PartialObserver (PartialObserver)
import Web.Firestore.QuerySnapshot (QuerySnapshot, forEach, queryDocumentReference)
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

-- SINGLE DOCUMENT

foreign import docImpl :: Fn2 Firestore String (Effect (DocumentReference DocumentData))

doc :: Firestore -> DocumentPath -> Effect (DocumentReference DocumentData)
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

foreign import docCollectionImpl :: forall a. Fn2 (DocumentReference a) String (Effect (CollectionReference DocumentData))

docCollection :: forall a. DocumentReference a -> CollectionPath -> Effect (CollectionReference DocumentData)
docCollection docRef path = runFn2 docCollectionImpl docRef (show path)

-- COLLECTIONS

foreign import collectionImpl :: Fn2 Firestore String (Effect (CollectionReference DocumentData))

collection :: Firestore -> CollectionPath -> Effect (CollectionReference DocumentData)
collection fs path = runFn2 collectionImpl fs (show path)

foreign import addImpl :: forall a. Fn2 (CollectionReference a) a (Effect (Promise (DocumentReference a)))

add :: forall a. CollectionReference a -> a -> Effect (Promise (DocumentReference a))
add = runFn2 addImpl

foreign import getCollectionImpl :: forall a. Fn2
  (CollectionReference a)
  (Nullable Json)
  (Effect (Promise (QuerySnapshot a)))

getCollection :: forall a. CollectionReference a -> Maybe GetOptions -> Effect (Promise (QuerySnapshot a))
getCollection collectionRef options = runFn2 getCollectionImpl collectionRef (toNullable $ encodeJson <$> options)

-- | deleting data from a web client is not recommended. You should avoid to use this function
-- |
-- | see https://firebase.google.com/docs/firestore/manage-data/delete-data for more details
clearCollection :: forall a. CollectionReference a -> Aff Unit
clearCollection collectionRef = do
  getPromise <- liftEffect $ getCollection collectionRef Nothing
  querySnapshot <- toAff getPromise
  forEach querySnapshot (\queryDocumentSnapshot -> do
    let queryDocRef = queryDocumentReference queryDocumentSnapshot
    deletePromise <- liftEffect $ delete queryDocRef
    toAff deletePromise)
