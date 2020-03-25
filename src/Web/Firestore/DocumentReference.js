"use strict";

const lodash = require('lodash')

const docRefPath = function (docRef) {
  const segments = docRef._key.path.segments
  const offset   = docRef._key.path.offset
  const length   = docRef._key.path.len

  return segments.slice(offset, offset + length)
}

exports.eqImpl = function (docRef1, docRef2) {
  return lodash.isEqual(docRefPath(docRef1), docRefPath(docRef2))
}

exports.showImpl = function (docRef) {
  const ret = {
    path: docRef._key.path
  }

  return JSON.stringify(ret)
}
