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
const lodash = require('lodash')

exports.pointImpl = function (lat, lon) {
  return new firebase.firestore.GeoPoint(lat, lon)
}

exports.eqImpl = function (pt1, pt2) {
  return lodash.isEqual(pt1, pt2)
}

exports.showImpl = function (pt) {
  const ret = {
    lat: pt.latitude,
    lon: pt.longitude
  }

  return JSON.stringify(ret)
}
