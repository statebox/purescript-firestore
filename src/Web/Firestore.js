"use strict";

const firebase = require('firebase')

exports.initializeAppImpl = function (options, name) {
  return function () {
    // optional arguments should be passed as `undefined` and not as `null`
    name = name === null ? undefined : name

    return firebase.initializeApp(options, name)
  }
}

exports.firestoreImpl = function (app) {
  return function () {
    return app.firestore()
  }
}

exports.docImpl = function (firestore, documentPath) {
  return function () {
    return firestore.doc(documentPath)
  }
}

exports.setImpl = function (documentReference, data, setOptions) {
  return function () {
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
}

exports.getImpl = function (documentReference, getOptions) {
  return function () {
    // optional arguments should be passed as `undefined` and not as `null`
    getOptions = getOptions === null ? undefined : getOptions

    return documentReference.get(getOptions)
  }
}

exports.dataImpl = function (documentSnapshot, snapshotOptions) {
  return function () {
    // optional arguments should be passed as `undefined` and not as `null`
    snapshotOptions = snapshotOptions === null ? undefined : snapshotOptions

    const ret = documentSnapshot.data(snapshotOptions)

    return ret === undefined ? null : ret
  }
}
