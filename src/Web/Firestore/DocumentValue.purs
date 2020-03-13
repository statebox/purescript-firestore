module Web.Firestore.DocumentValue where

import Prelude
import Control.Alt ((<|>))
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)
import Foreign.Object (Object)

import Web.Firestore.PrimitiveValue (PrimitiveValue)

newtype MapValue = MapValue (Object DocumentValue)

instance encodeJsonMapValue :: EncodeJson MapValue where
  encodeJson (MapValue obj) = encodeJson obj

instance decodeJsonMapValue :: DecodeJson MapValue where
  decodeJson json = MapValue <$> decodeJson json

instance showMapValue :: Show MapValue where
  show (MapValue obj) = show obj

instance eqMapValue :: Eq MapValue where
  eq (MapValue obj1) (MapValue obj2) = eq obj1 obj2

data ArrayEntry
  = PrimitiveArrayValue PrimitiveValue
  | MapArrayValue MapValue

instance encodeJsonArrayEntry :: EncodeJson ArrayEntry where
  encodeJson = case _ of
    PrimitiveArrayValue pv -> encodeJson pv
    MapArrayValue       mv -> encodeJson mv

instance showArrayEntry :: Show ArrayEntry where
  show = case _ of
    PrimitiveArrayValue pv -> show pv
    MapArrayValue       mv -> show mv

instance decodeJsonArrayEntry :: DecodeJson ArrayEntry where
  decodeJson json
    =   (PrimitiveArrayValue <$> decodeJson json)
    <|> (MapArrayValue       <$> decodeJson json)

instance eqArrayEntry :: Eq ArrayEntry where
  eq (PrimitiveArrayValue pv1) (PrimitiveArrayValue pv2) = eq pv1 pv2
  eq (MapArrayValue       mv1) (MapArrayValue       mv2) = eq mv1 mv2
  eq _                         _                         = false

newtype ArrayValue = ArrayValue (Array ArrayEntry)

instance decodeJsonArrayValue :: DecodeJson ArrayValue where
  decodeJson json = ArrayValue <$> decodeJson json

instance eqArrayValue :: Eq ArrayValue where
  eq (ArrayValue e1) (ArrayValue e2) = eq e1 e2

data DocumentValue
  = PrimitiveDocument PrimitiveValue
  | MapDocument MapValue
  | ArrayDocument ArrayValue

instance encodeJsonDocumentValue :: EncodeJson DocumentValue where
  encodeJson = case _ of
    PrimitiveDocument primitiveValue     -> encodeJson primitiveValue
    MapDocument       (MapValue obj)     -> encodeJson obj
    ArrayDocument     (ArrayValue array) -> encodeJson array

instance decodeJsonDocumentValue :: DecodeJson DocumentValue where
  decodeJson json
    =   (PrimitiveDocument <$> decodeJson json)
    <|> (MapDocument       <$> decodeJson json)
    <|> (ArrayDocument     <$> decodeJson json)

instance showDocumentValue :: Show DocumentValue where
  show = case _ of
    PrimitiveDocument primitiveValue     -> show primitiveValue
    MapDocument       (MapValue obj)     -> show obj
    ArrayDocument     (ArrayValue array) -> show array

instance eqDocumentValue :: Eq DocumentValue where
  eq (PrimitiveDocument pd1) (PrimitiveDocument pd2) = eq pd1 pd2
  eq (MapDocument       md1) (MapDocument       md2) = eq md1 md2
  eq (ArrayDocument     ad1) (ArrayDocument     ad2) = eq ad1 ad2
  eq _                       _                       = false
