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
