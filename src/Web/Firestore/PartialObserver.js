"use strict";

exports.partialObserverImpl = function (next, error, complete) {
  return {
    next: next,
    error: error,
    complete: complete
  }
}
