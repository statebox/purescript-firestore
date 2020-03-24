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
import Data.Function.Uncurried (Fn1, Fn2, runFn1, runFn2)
import Foreign.Object (Object)

import Web.Firestore.PrimitiveValue (PrimitiveValue)

foreign import data ArrayEntry :: Type

foreign import primitiveArrayValueImpl :: Fn1 PrimitiveValue ArrayEntry

primitiveArrayValue :: PrimitiveValue -> ArrayEntry
primitiveArrayValue = runFn1 primitiveArrayValueImpl

foreign import mapArrayValueImpl :: Fn1 (Object DocumentValue) ArrayEntry

mapArrayValue :: Object DocumentValue -> ArrayEntry
mapArrayValue = runFn1 mapArrayValueImpl

foreign import data DocumentValue :: Type

foreign import showDocumentValueImpl :: Fn1 DocumentValue String

instance showDocumentValue :: Show DocumentValue where
  show = runFn1 showDocumentValueImpl

foreign import eqDocumentValueImpl :: Fn2 DocumentValue DocumentValue Boolean

instance eqDocumentValue :: Eq DocumentValue where
  eq = runFn2 eqDocumentValueImpl

foreign import primitiveDocumentImpl :: Fn1 PrimitiveValue DocumentValue

primitiveDocument :: PrimitiveValue -> DocumentValue
primitiveDocument = runFn1 primitiveDocumentImpl

foreign import mapDocumentImpl :: Fn1 (Object DocumentValue) DocumentValue

mapDocument :: Object DocumentValue -> DocumentValue
mapDocument = runFn1 mapDocumentImpl

foreign import arrayDocumentImpl :: Fn1 (Array ArrayEntry) DocumentValue

arrayDocument :: Array ArrayEntry -> DocumentValue
arrayDocument = runFn1 arrayDocumentImpl
