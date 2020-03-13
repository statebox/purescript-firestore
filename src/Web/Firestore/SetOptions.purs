module Web.Firestore.SetOptions where

type Merge = Boolean

foreign import data MergeField :: Type

foreign import stringMergeField :: String -> MergeField

foreign import fieldPathMergeField :: Array String -> MergeField

type MergeFields = Array MergeField

foreign import data SetOptions :: Type

foreign import mergeOption :: Merge -> SetOptions

foreign import mergeFieldsOption :: MergeFields -> SetOptions
