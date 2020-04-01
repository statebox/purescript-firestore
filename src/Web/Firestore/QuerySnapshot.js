"use strict";

exports.forEachImpl = function (snapshot, callback) {
  return function () {
    return snapshot.forEach(function (documentSnapshot) {
      return callback(documentSnapshot)()
    })
  }
}
