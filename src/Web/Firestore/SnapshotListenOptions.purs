module Web.Firestore.SnapshotListenOptions where

newtype SnapshotListenOptions = SnapshotListenOptions
  { includeMetadataChanges :: Boolean
  }
