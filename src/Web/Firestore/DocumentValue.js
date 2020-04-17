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
const docRef = require("../Web.Firestore.DocumentReference")

exports.primitiveArrayValueImpl = function (primitiveValue) {
  return primitiveValue
}

exports.mapArrayValueImpl = function (objectDocuments) {
  return objectDocuments
}

exports.eqArrayEntryImpl = function (onPrimitiveValue, onMap, doc1, doc2) {
  if (onPrimitiveValue(doc1, doc2)) {
    return true
  }

  if (typeof doc1 === 'object' && typeof doc2 === 'object') {
    return onMap(doc1, doc2)
  }

  return false
}

exports.primitiveDocumentImpl = function (primitiveValue) {
  return primitiveValue
}

exports.mapDocumentImpl = function (objectDocuments) {
  return objectDocuments
}

exports.arrayDocumentImpl = function (arrayEntries) {
  return arrayEntries
}

exports.showDocumentValueImpl = function (doc) {
  if (doc instanceof firebase.firestore.DocumentReference) {
    return docRef.showImpl(doc)
  }

  return JSON.stringify(doc)
}

exports.eqDocumentValueImpl = function (onPrimitiveValue, onMap, onArray, doc1, doc2) {
  if (Array.isArray(doc1) && Array.isArray(doc2)) {
    return onArray(doc1)(doc2)
  }

  if (onPrimitiveValue(doc1)(doc2)) {
    return true
  }

  if (typeof doc1 === 'object' && typeof doc2 === 'object') {
    return onMap(doc1)(doc2)
  }

  return false
}
