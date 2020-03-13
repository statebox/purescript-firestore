module Web.Firestore where

import Prelude
import Control.Promise (Promise)
import Data.Argonaut (class DecodeJson, class EncodeJson, Json, decodeJson, encodeJson)
import Data.Either (either)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, runFn1, runFn2, runFn3)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)

import Web.Firestore.DocumentData (DocumentData)
import Web.Firestore.GetOptions (GetOptions)
import Web.Firestore.Options (Options)
import Web.Firestore.Path (Path)
import Web.Firestore.SetOptions (SetOptions)
import Web.Firestore.SnapshotOptions (SnapshotOptions)

foreign import data App :: Type

foreign import initializeAppImpl :: Fn2 Json (Nullable String) App

initializeApp :: Options -> Maybe String -> App
initializeApp options name = runFn2 initializeAppImpl (encodeJson options) (toNullable name)

foreign import data Firestore :: Type

foreign import firestoreImpl :: Fn1 App Firestore

firestore :: App -> Firestore
firestore = runFn1 firestoreImpl

-- TODO: should this be a newtype or a foreign import?
-- newtype DocumentReference a = DocumentReference a

foreign import data DocumentReference :: Type -> Type

foreign import docImpl :: Fn2 Firestore String (DocumentReference DocumentData)

doc :: Firestore -> Path -> DocumentReference DocumentData
doc fs path = runFn2 docImpl fs (show path)

foreign import setImpl :: forall a. Fn3 (DocumentReference a) Json (Nullable SetOptions) (Promise Unit)

set :: forall a. EncodeJson a => DocumentReference a -> a -> Maybe SetOptions -> Promise Unit
set docRef a options = runFn3 setImpl docRef (encodeJson a) (toNullable options)

-- TODO: should this be a newtype or a foreign import?
-- newtype DocumentSnapshot a = DocumentSnapshot a

foreign import data DocumentSnapshot :: Type -> Type

foreign import getImpl :: forall a. Fn2 (DocumentReference a) (Nullable GetOptions) (Promise (DocumentSnapshot a))

get :: forall a. DocumentReference a -> Maybe GetOptions -> Promise (DocumentSnapshot a)
get docRef options = (runFn2 getImpl) docRef (toNullable options)

foreign import dataImpl :: forall a. Fn2 (DocumentSnapshot a) (Nullable SnapshotOptions) Json

snapshotData :: forall a. DecodeJson a => DocumentSnapshot a -> Maybe SnapshotOptions -> Maybe a
snapshotData docSnapshot options = either
  (const Nothing)
  identity
  (decodeJson $ runFn2 dataImpl docSnapshot (toNullable options))
