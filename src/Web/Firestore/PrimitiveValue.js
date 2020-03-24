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

exports.evalPrimitiveValueImpl = function
  ( onBytes
  , onBool
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

    if (typeof value === 'number') {
      return onNumber(value)
    }

    console.log(value, typeof value)

    return null
}
