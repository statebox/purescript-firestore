module Web.Firestore.Path (Path, path, pathFromString) where

import Prelude
import Data.Array (length)
import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), split)

-- | A slash-separated path to a document
newtype Path = Path (Array String)

instance showPath :: Show Path where
  show (Path sections) = intercalate "/" sections

path :: Array String -> Maybe Path
path sections = if mod (length sections) 2 == 0
  then Just $ Path sections
  else Nothing

pathFromString :: String -> Maybe Path
pathFromString = path <<< split (Pattern "/")
