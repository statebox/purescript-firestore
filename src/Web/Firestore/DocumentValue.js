"use strict";

const firebase = require('firebase')
const lodash = require('lodash')
const docRef = require("../Web.Firestore.DocumentReference")

exports.primitiveArrayValueImpl = function (primitiveValue) {
  return primitiveValue
}

exports.mapArrayValueImpl = function (objectDocuments) {
  return objectDocuments
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

exports.eqDocumentValueImpl = function (doc1, doc2) {
  return lodash.isEqual(doc1, doc2)
}
