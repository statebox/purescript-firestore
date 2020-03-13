module Web.Firestore.LatLon where

import Prelude
import Data.Argonaut (class DecodeJson, class EncodeJson, decodeJson, encodeJson)

newtype Lat = Lat Number

instance encodeJsonLat :: EncodeJson Lat where
  encodeJson (Lat n) = encodeJson n

instance decodeJsonLat :: DecodeJson Lat where
  decodeJson json = Lat <$> decodeJson json

instance showLat :: Show Lat where
  show (Lat n) = show n

instance eqLat :: Eq Lat where
  eq (Lat n1) (Lat n2) = eq n1 n2

newtype Lon = Lon Number

instance encodeJsonLon :: EncodeJson Lon where
  encodeJson (Lon n) = encodeJson n

instance decodeJsonLon :: DecodeJson Lon where
  decodeJson json = Lon <$> decodeJson json

instance showLon :: Show Lon where
  show (Lon n) = show n

instance eqLon :: Eq Lon where
  eq (Lon n1) (Lon n2) = eq n1 n2
