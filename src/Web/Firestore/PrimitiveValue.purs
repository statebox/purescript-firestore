module Web.Firestore.PrimitiveValue where

import Prelude
import Control.Alt ((<|>))
import Data.Argonaut (class DecodeJson, class EncodeJson, caseJsonNull, decodeJson, encodeJson, jsonNull)
import Data.Either (Either(..))

import Web.Firestore.ByteString (FSByteString)
import Web.Firestore.LatLon (Lat, Lon)
import Web.Firestore.PreciseDateTime (FSPreciseDateTime)

data PrimitiveValue
  = PVBoolean Boolean
  | PVBytes FSByteString
  -- | Firestore is precise only up to microseconds
  | PVDateTime FSPreciseDateTime
  | PVFloat Number
  | PVGeographicalPoint Lat Lon
  | PVInteger Int
  | PVNull
  | PVReference String
  | PVText String

instance encodeJsonPrimitiveValue :: EncodeJson PrimitiveValue where
  encodeJson = case _ of
    PVBoolean           b       -> encodeJson b
    PVBytes             bs      -> encodeJson bs
    PVDateTime          dt      -> encodeJson dt
    PVFloat             n       -> encodeJson n
    PVGeographicalPoint lat lon -> encodeJson { lat: lat, lon: lon }
    PVInteger           i       -> encodeJson i
    PVNull                      -> jsonNull
    PVReference         s       -> encodeJson s
    PVText              s       -> encodeJson s

instance decodeJsonPrimitiveValue :: DecodeJson PrimitiveValue where
  decodeJson json
    =   (PVBoolean           <$> decodeJson json)
    -- <|> (PVBytes             <$> decodeJson json) -- TODO: how do I decode bytes?
    -- <|> (PVDateTime          <$> decodeJson json) -- TODO: how doe we parse a DateTime? how is it represented in Firestore?
    <|> (PVInteger           <$> decodeJson json)
    <|> (PVFloat             <$> decodeJson json)
    <|> ((\({lat: lat, lon: lon} :: {lat:: Lat, lon:: Lon}) -> PVGeographicalPoint lat lon) <$> decodeJson json)
    <|> (caseJsonNull (Left "not null") (const $ Right PVNull) json)
    -- <|> (PVReference         <$> decodeJson json) -- TODO: parse only strings with the correct format
    <|> (PVText              <$> decodeJson json)

instance showPrimitiveValue :: Show PrimitiveValue where
  show = case _ of
    PVBoolean           b       -> show b
    PVBytes             bs      -> show bs
    PVDateTime          dt      -> show dt
    PVFloat             n       -> show n
    PVGeographicalPoint lat lon -> show { lat: lat, lon: lon }
    PVInteger           i       -> show i
    PVNull                      -> "null"
    PVReference         s       -> show s
    PVText              s       -> show s

instance eqPrimitiveValue :: Eq PrimitiveValue where
  eq (PVBoolean           b1       ) (PVBoolean           b2       ) = eq b1  b2
  eq (PVBytes             bs1      ) (PVBytes             bs2      ) = eq bs1 bs2
  eq (PVDateTime          dt1      ) (PVDateTime          dt2      ) = eq dt1 dt2
  eq (PVFloat             f1       ) (PVFloat             f2       ) = eq f1  f2
  eq (PVGeographicalPoint lat1 lon1) (PVGeographicalPoint lat2 lon2) = eq lat1 lat2 && eq lon1 lon2
  eq (PVInteger           i1       ) (PVInteger           i2       ) = eq i1  i2
  eq (PVNull                       ) (PVNull                       ) = true
  eq (PVReference         r1       ) (PVReference         r2       ) = eq r1  r2
  eq (PVText              t1       ) (PVText              t2       ) = eq t1  t2
  eq _                               _                               = false
