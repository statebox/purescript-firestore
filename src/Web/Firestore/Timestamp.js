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
