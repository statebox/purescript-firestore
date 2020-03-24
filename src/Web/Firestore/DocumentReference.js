"use strict";

exports.eqImpl = function (docRef1, docRef2) {
  return docRef1._key.path === docRef2._key.path
}

exports.showImpl = function (docRef) {
  const ret = {
    path: docRef._key.path.segments
  }

  return JSON.stringify(ret)
}
