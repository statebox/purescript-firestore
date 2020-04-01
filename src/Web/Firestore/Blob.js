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
