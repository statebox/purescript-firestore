module Web.Firestore.CollectionPath (CollectionPath, path, pathFromString) where

import Prelude
import Control.Bind (bindFlipped)
import Data.Array.NonEmpty (NonEmptyArray, fromArray, length)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)

-- | A non-empty slash-separated path to a document
newtype CollectionPath = CollectionPath (NonEmptyArray String)

instance showCollectionPath :: Show CollectionPath where
  show (CollectionPath sections) = intercalate "/" sections

path :: NonEmptyArray String -> Maybe CollectionPath
path sections = if mod (length sections) 2 == 1
  then Just $ CollectionPath sections
  else Nothing

pathFromString :: String -> Maybe CollectionPath
pathFromString = bindFlipped path <<< fromArray <<< split (Pattern "/")
