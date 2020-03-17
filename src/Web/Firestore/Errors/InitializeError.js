"use strict";

exports.fromFirebaseErrorImpl = function (fromString, firebaseError) {
  return fromString(firebaseError.stack)
}
