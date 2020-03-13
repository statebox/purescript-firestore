module Web.Firestore.DocumentData where

import Prelude
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Foreign.Object (Object)

import Web.Firestore.DocumentValue (DocumentValue)

newtype DocumentData = DocumentData (Object DocumentValue)

instance encodeJsonDocumentData :: EncodeJson DocumentData where
  encodeJson (DocumentData obj) = encodeJson obj

instance decodeJsonDocumentData :: DecodeJson DocumentData where
  decodeJson = (DocumentData <$> _) <<< decodeJson

instance showDocumentData :: Show DocumentData where
  show (DocumentData obj) = show obj

instance eqDocumentData :: Eq DocumentData where
  eq (DocumentData obj1) (DocumentData obj2) = eq obj1 obj2
