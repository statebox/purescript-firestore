module Web.Firestore.ByteString where

import Prelude
import Data.Argonaut (class EncodeJson, encodeJson)
import Data.ByteString (ByteString)

newtype FSByteString = FSByteString ByteString

instance encodeJsonFSByteString :: EncodeJson FSByteString where
  encodeJson (FSByteString bs) = encodeJson $ show bs

instance showFSByteString :: Show FSByteString where
  show (FSByteString bs) = show bs

instance eqFSByteString :: Eq FSByteString where
  eq (FSByteString bs1) (FSByteString bs2) = eq bs1 bs2
