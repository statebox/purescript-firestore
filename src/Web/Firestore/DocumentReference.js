"use strict";

exports.showDocumentReferenceImpl = function (docRef)
{
  const ret = {
    path: docRef._key.path.segments
  }

  return JSON.stringify(ret)
}
