{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.DocumentValue
( ArrayEntry
, DocumentValue
, arrayDocument
, mapArrayValue
, mapDocument
, primitiveArrayValue
, primitiveDocument
) where

import Prelude
import Data.Function.Uncurried (Fn1, Fn4, Fn5, runFn1, runFn4, runFn5)
import Foreign.Object (Object)

import Web.Firestore.PrimitiveValue (PrimitiveValue)

foreign import data ArrayEntry :: Type

foreign import primitiveArrayValueImpl :: Fn1 PrimitiveValue ArrayEntry

primitiveArrayValue :: PrimitiveValue -> ArrayEntry
primitiveArrayValue = runFn1 primitiveArrayValueImpl

foreign import mapArrayValueImpl :: Fn1 (Object DocumentValue) ArrayEntry

mapArrayValue :: Object DocumentValue -> ArrayEntry
mapArrayValue = runFn1 mapArrayValueImpl

foreign import eqArrayEntryImpl :: Fn4
  (PrimitiveValue       -> PrimitiveValue       -> Boolean)
  (Object DocumentValue -> Object DocumentValue -> Boolean)
   ArrayEntry              ArrayEntry              Boolean

instance eqArrayEntry :: Eq ArrayEntry where
  eq = runFn4 eqArrayEntryImpl (\a b -> eq a b) (\a b -> eq a b)

foreign import data DocumentValue :: Type

foreign import showDocumentValueImpl :: Fn1 DocumentValue String

instance showDocumentValue :: Show DocumentValue where
  show = runFn1 showDocumentValueImpl

foreign import primitiveDocumentImpl :: Fn1 PrimitiveValue DocumentValue

primitiveDocument :: PrimitiveValue -> DocumentValue
primitiveDocument = runFn1 primitiveDocumentImpl

foreign import mapDocumentImpl :: Fn1 (Object DocumentValue) DocumentValue

mapDocument :: Object DocumentValue -> DocumentValue
mapDocument = runFn1 mapDocumentImpl

foreign import arrayDocumentImpl :: Fn1 (Array ArrayEntry) DocumentValue

arrayDocument :: Array ArrayEntry -> DocumentValue
arrayDocument = runFn1 arrayDocumentImpl

foreign import eqDocumentValueImpl :: Fn5
  (PrimitiveValue       -> PrimitiveValue       -> Boolean)
  (Object DocumentValue -> Object DocumentValue -> Boolean)
  (Array ArrayEntry     -> Array ArrayEntry     -> Boolean)
   DocumentValue           DocumentValue           Boolean

instance eqDocumentValue :: Eq DocumentValue where
  eq = runFn5 eqDocumentValueImpl (\a b -> eq a b) (\a b -> eq a b) (\a b -> eq a b)
