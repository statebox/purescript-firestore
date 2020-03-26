"use strict";

const firebase = require('firebase')

exports.pvBytesImpl = function (blob) {
  return blob
}

exports.pvBooleanImpl = function (boolean) {
  return boolean
}

exports.pvDateTimeImpl = function (timestamp) {
  return timestamp
}

exports.pvGeographicalPointImpl = function (point) {
  return point
}

exports.pvNullImpl = function () {
  return null
}

exports.pvNumberImpl = function (number) {
  return number
}

exports.pvReferenceImpl = function (reference) {
  return reference
}

exports.pvTextImpl = function (text) {
  return text
}

exports.eqPrimitiveValueImpl = function
  ( onBool
  , onBytes
  , onDateTime
  , onGeographicalPoint
  , onNumber
  , onReference
  , onText
  , value1
  , value2
  ) {
    if (typeof value1 === 'boolean' && typeof value2 === 'boolean') {
      return onBool(value1, value2)
    }

    if (value1 instanceof firebase.firestore.Blob && value2 instanceof firebase.firestore.Blob) {
      return onBytes(value1, value2)
    }

    if (value1 instanceof firebase.firestore.Timestamp && value2 instanceof firebase.firestore.Timestamp) {
      return onDateTime(value1, value2)
    }

    if (value1 instanceof firebase.firestore.GeoPoint && value1 instanceof firebase.firestore.GeoPoint) {
      return onGeographicalPoint(value1, value2)
    }

    if (value1 === null && value2 === null) {
      return true
    }

    if (typeof value1 === 'number' && typeof value2 === 'number') {
      return onNumber(value1, value2)
    }

    if (value1 instanceof firebase.firestore.DocumentReference && value2 instanceof firebase.firestore.DocumentReference) {
      return onReference(value1, value2)
    }

    if (typeof value1 === 'string' && typeof value2 === 'string') {
      return onText(value1, value2)
    }

    return false
}

exports.evalPrimitiveValueImpl = function
  ( onBool
  , onBytes
  , onDateTime
  , onGeographicalPoint
  , onNull
  , onNumber
  , onReference
  , onText
  , value
  ) {
    if (value instanceof firebase.firestore.Blob) {
      return onBytes(value)
    }

    if (typeof value === 'boolean') {
      return onBool(value)
    }

    if (value instanceof firebase.firestore.Timestamp) {
      return onDateTime(value)
    }

    if (value instanceof firebase.firestore.GeoPoint) {
      return onGeographicalPoint(value)
    }

    if (value === null) {
      return onNull
    }

    if (typeof value === 'number') {
      return onNumber(value)
    }

    if (value instanceof firebase.firestore.DocumentReference) {
      return onReference(value)
    }

    if (typeof value === 'string') {
      return onText(value)
    }

    throw new Error("Value or an unrecognised type")
}
