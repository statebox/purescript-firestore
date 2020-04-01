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

const firebase = require('firebase')

exports.stringMergeField = function (field) {
  return field
}

exports.fieldPathMergeField = function (fieldNames) {
  return new firebase.firestore.FieldPath(...fieldNames)
}

exports.mergeOption = function (merge) {
  return {
    merge: merge
  }
}

exports.mergeFieldsOption = function (mergeFields) {
  return {
    mergeFields: mergeFields
  }
}
