module Web.Firestore
( App
, DocumentReference
, DocumentSnapshot
, Firestore
, delete
, deleteApp
, doc
, firestore
, get
, initializeApp
, set
, snapshotData
) where

import Prelude
import Control.Promise (Promise)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson)
import Data.Either (Either(..), hush)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, Fn4, runFn1, runFn2, runFn3, runFn4)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.Profunctor.Choice ((+++))
import Effect (Effect)

import Web.Firestore.DocumentData (DocumentData)
import Web.Firestore.Errors.FirebaseError (FirebaseError, fromFirebaseError, fromString)
import Web.Firestore.Error.FirestoreError (FirestoreError)
import Web.Firestore.Errors.InitializeError (InitializeError)
import Web.Firestore.GetOptions (GetOptions)
import Web.Firestore.Options (Options)
import Web.Firestore.Path (Path)
import Web.Firestore.SetOptions (SetOptions)
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

foreign import data DocumentReference :: Type -> Type

foreign import showDocumentReferenceImpl :: forall a. Fn1 (DocumentReference a) String

instance showDocumentReference :: Show a => Show (DocumentReference a) where
  show = runFn1 showDocumentReferenceImpl

foreign import docImpl :: Fn2 Firestore String (Effect (DocumentReference DocumentData))

doc :: Firestore -> Path -> Effect (DocumentReference DocumentData)
doc fs path = runFn2 docImpl fs (show path)

foreign import setImpl :: forall a. Fn3 (DocumentReference a) Json (Nullable SetOptions) (Effect (Promise Unit))

set :: forall a. EncodeJson a => DocumentReference a -> a -> Maybe SetOptions -> Effect (Promise Unit)
set docRef a options = runFn3 setImpl docRef (encodeJson a) (toNullable options)

foreign import deleteImpl :: forall a. Fn1 (DocumentReference a) (Effect (Promise Unit))

delete :: forall a. DocumentReference a -> Effect (Promise Unit)
delete = runFn1 deleteImpl

foreign import data DocumentSnapshot :: Type -> Type

foreign import getImpl :: forall a. Fn2 (DocumentReference a) (Nullable Json) (Effect (Promise (DocumentSnapshot a)))

get :: forall a. DocumentReference a -> Maybe GetOptions -> Effect (Promise (DocumentSnapshot a))
get docRef options = (runFn2 getImpl) docRef (toNullable $ encodeJson <$> options)

foreign import dataImpl :: forall a. Fn2 (DocumentSnapshot a) (Nullable Json) (Effect Json)

snapshotData :: forall a. DecodeJson a => DocumentSnapshot a -> Maybe SnapshotOptions -> Effect (Maybe a)
snapshotData docSnapshot options = hush <<< decodeJson <$> runFn2 dataImpl docSnapshot (toNullable $ encodeJson <$> options)
