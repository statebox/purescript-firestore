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
