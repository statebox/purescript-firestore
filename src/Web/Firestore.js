"use strict";

const firebase = require('firebase')

exports.initializeAppImpl = function (options, name) {
  // optional arguments should be passed as `undefined` and not as `null`
  name = name === null ? undefined : name

  return firebase.initializeApp(options, name)
}

exports.firestoreImpl = function (app) {
  return app.firestore()
}

exports.docImpl = function (firestore, documentPath) {
  return firestore.doc(documentPath)
}

exports.setImpl = function (documentReference, data, setOptions) {
  let ret = undefined

  // optional arguments should be passed as `undefined` and not as `null`
  setOptions = setOptions === null ? undefined : setOptions

  try {
    ret = documentReference.set(data, setOptions)
  } catch (firestoreError) {
    ret = Promise.reject(firestoreError)
  }

  return ret
}

exports.getImpl = function (documentReference, getOptions) {
  // optional arguments should be passed as `undefined` and not as `null`
  getOptions = getOptions === null ? undefined : getOptions

  return documentReference.get(getOptions)
}

exports.dataImpl = function (documentSnapshot, snapshotOptions) {
  // optional arguments should be passed as `undefined` and not as `null`
  snapshotOptions = snapshotOptions === null ? undefined : snapshotOptions

  const ret = documentSnapshot.data(snapshotOptions)

  return ret === undefined ? null : ret
}
