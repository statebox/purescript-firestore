"use strict";

const firebase = require('firebase')

exports.blobImpl = function (string) {
  const encoded = Buffer.from(string, 'utf16le').toString('base64')

  return new firebase.firestore.Blob.fromBase64String(encoded)
}

exports.eqImpl = function (blob1, blob2) {
  return blob1.toBase64() === blob2.toBase64()
}

exports.showImpl = function (blob) {
  return (Buffer.from(blob._binaryString, 'binary')).toString('utf16le')
}
