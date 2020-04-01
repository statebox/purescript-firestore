module Web.Firestore.DocumentPath (DocumentPath, path, pathFromString) where

import Prelude
import Control.Bind (bindFlipped)
import Data.Array.NonEmpty (NonEmptyArray, fromArray, length)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)

-- | A non-empty slash-separated path to a document
newtype DocumentPath = DocumentPath (NonEmptyArray String)

instance showDocumentPath :: Show DocumentPath where
  show (DocumentPath sections) = intercalate "/" sections

path :: NonEmptyArray String -> Maybe DocumentPath
path sections = if mod (length sections) 2 == 0
  then Just $ DocumentPath sections
  else Nothing

pathFromString :: String -> Maybe DocumentPath
pathFromString = bindFlipped path <<< fromArray <<< split (Pattern "/")
