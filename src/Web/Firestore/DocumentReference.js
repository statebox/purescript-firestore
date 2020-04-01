/*
This file is part of `purescript-firestore`, a Purescript libary to
interact with Google Cloud Firestore.

Copyright (C) 2020 Stichting Statebox <https://statebox.nl>

This program is licensed under the terms of the Hippocratic License, as
published on `firstdonoharm.dev`, version 2.1.

You should have received a copy of the Hippocratic License along with
this program. If not, see <https://firstdonoharm.dev/>.
*/

"use strict";

const docRefPath = function (docRef) {
  const segments = docRef._key.path.segments
  const offset   = docRef._key.path.offset
  const length   = docRef._key.path.len

  return segments.slice(offset, offset + length)
}

exports.eqImpl = function (docRef1, docRef2) {
  return docRef1.isEqual(docRef2)
}

exports.showImpl = function (docRef) {
  const ret = {
    path: docRef._key.path
  }

  return JSON.stringify(ret)
}
