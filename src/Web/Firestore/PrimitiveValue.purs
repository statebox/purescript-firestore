module Web.Firestore.PrimitiveValue
( PrimitiveValue
, evalPrimitiveValue
, pvBytes
, pvBoolean
, pvDateTime
, pvGeographicalPoint
, pvNull
, pvNumber
, pvReference
, pvText
) where

import Data.Function.Uncurried (Fn0, Fn1, Fn9, runFn0, runFn1, runFn9)

import Web.Firestore.Blob (Blob)
import Web.Firestore.DocumentReference (DocumentReference)
import Web.Firestore.GeographicalPoint (GeographicalPoint)
import Web.Firestore.Timestamp (Timestamp)

foreign import data PrimitiveValue :: Type

foreign import pvBooleanImpl :: Fn1 Boolean PrimitiveValue

pvBoolean :: Boolean -> PrimitiveValue
pvBoolean = runFn1 pvBooleanImpl

foreign import pvBytesImpl :: Fn1 Blob PrimitiveValue

pvBytes :: Blob -> PrimitiveValue
pvBytes = runFn1 pvBytesImpl

foreign import pvDateTimeImpl :: Fn1 Timestamp PrimitiveValue

pvDateTime :: Timestamp -> PrimitiveValue
pvDateTime ts = runFn1 pvDateTimeImpl ts

foreign import pvGeographicalPointImpl :: Fn1 GeographicalPoint PrimitiveValue

pvGeographicalPoint :: GeographicalPoint -> PrimitiveValue
pvGeographicalPoint = runFn1 pvGeographicalPointImpl

foreign import pvNullImpl :: Fn0 PrimitiveValue

pvNull :: PrimitiveValue
pvNull = runFn0 pvNullImpl

foreign import pvNumberImpl :: Fn1 Number PrimitiveValue

pvNumber :: Number -> PrimitiveValue
pvNumber = runFn1 pvNumberImpl

foreign import pvReferenceImpl :: forall a. Fn1 (DocumentReference a) PrimitiveValue

pvReference :: forall a. DocumentReference a -> PrimitiveValue
pvReference = runFn1 pvReferenceImpl

foreign import pvTextImpl :: Fn1 String PrimitiveValue

pvText :: String -> PrimitiveValue
pvText = runFn1 pvTextImpl

foreign import evalPrimitiveValueImpl :: forall a b. Fn9
  (Blob -> a)
  (Boolean -> a)
  (Timestamp -> a)
  (GeographicalPoint -> a)
  a
  (Number -> a)
  (DocumentReference b -> a)
  (String -> a)
  PrimitiveValue
  a

evalPrimitiveValue :: forall a b.
  (Blob -> a) ->
  (Boolean -> a) ->
  (Timestamp -> a) ->
  (GeographicalPoint -> a) ->
  a ->
  (Number -> a) ->
  (DocumentReference b -> a) ->
  (String -> a) ->
  PrimitiveValue -> a
evalPrimitiveValue = runFn9 evalPrimitiveValueImpl
