module Web.Firestore.DocumentData where

import Prelude
import Foreign.Object (Object)

import Web.Firestore.DocumentValue (DocumentValue)

newtype DocumentData = DocumentData (Object DocumentValue)

instance showDocumentData :: Show DocumentData where
  show (DocumentData obj) = show obj

instance eqDocumentData :: Eq DocumentData where
  eq (DocumentData obj1) (DocumentData obj2) = eq obj1 obj2
