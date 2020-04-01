"use strict";

exports.showImpl = function (collectionRef) {
  const ret = {
    path: collectionRef._path
  }

  return JSON.stringify(ret)
}
