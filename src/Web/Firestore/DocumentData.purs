{-
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
-}

module Web.Firestore.DocumentData where

import Prelude
import Foreign.Object (Object)

import Web.Firestore.DocumentValue (DocumentValue)

newtype DocumentData = DocumentData (Object DocumentValue)

instance showDocumentData :: Show DocumentData where
  show (DocumentData obj) = show obj

instance eqDocumentData :: Eq DocumentData where
  eq (DocumentData obj1) (DocumentData obj2) = eq obj1 obj2
