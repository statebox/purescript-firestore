"use strict";

exports.showImpl = function (collectionRef) {
  const ret = {
    path: collectionRef._key.path
  }

  return JSON.stringify(ret)
}
