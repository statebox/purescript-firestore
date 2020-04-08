"use strict";

exports.forEachImpl = function (snapshot, callback) {
  return function () {
    return snapshot.forEach(function (documentSnapshot) {
      return callback(documentSnapshot)()
    })
  }
}

exports.queryDocumentDataImpl = function (documentSnapshot, options) {
  options = options === null ? undefined : options

  return documentSnapshot.data()
}

exports.queryDocumentReferenceImpl = function (documentSnapshot) {
  return documentSnapshot.ref
}
