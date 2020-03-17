"use strict";

const firebase = require('firebase')
const lodash = require('lodash')

exports.showAppImpl = function (app) {
  const ret = {
    name: app.name_,
    options : app.options_
  }

  return JSON.stringify(ret)
}

exports.eqAppImpl = function (app1, app2) {
  return lodash.isEqual(app1, app2)
}

exports.initializeAppImpl = function (left, right, options, name) {
  return function () {
    // optional arguments should be passed as `undefined` and not as `null`
    name = name === null ? undefined : name

    try {
      const app = firebase.initializeApp(options, name)

      return right(app)
    } catch (error) {
      return left(error)
    }
  }
}

exports.deleteAppImpl = function (app) {
  return function () {
    return app.delete()
  }
}

exports.showFirestoreImpl = function (firestore) {
  const ret = {
    databaseId: firestore._databaseId,
    persistenceKey: firestore._persistenceKey,
    settings: firestore._settings
  }

  return JSON.stringify(ret)
}

exports.firestoreImpl = function (left, right, app) {
  return function () {
    try {
      const firestore = app.firestore()

      return right(firestore)
    } catch (error) {
      return left(error)
    }
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
