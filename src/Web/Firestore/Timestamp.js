"use strict";

const firebase = require('firebase')

exports.timestampImpl = function (seconds, microseconds) {
  return new firebase.firestore.Timestamp(seconds, microseconds * 1000)
}

exports.eqImpl = function (ts1, ts2) {
  return ts1.isEqual(ts2)
}

exports.showImpl = function (ts) {
  return ts.toString()
}

exports.timestampSecondsImpl = function (ts) {
  return ts.seconds
}

exports.timestampMicrosecondsImpl = function (ts) {
  return ts.nanoseconds / 1000
}
