# purescript-firestore

A Purescript library to interact with [Google Cloud Firestore](https://firebase.google.com/docs/firestore/).

The library is a work in progress and for the moment it exposes only a subset of the actual Firestore API.
Basically at the moment you can read, write, delete and subscribe to the changes of a single document.
You can execute every operation singularly on together in a batch.
Please take a look at the test in [FirestoreSpec.purs](test/Web/FirestoreSpec.purs) to see how to use the provided functions.

## build

You can install the dependencies using

```
npm i
```

and the build the library with

```
npm run build
```

or

```
npm run watch
```

## test

Firestore does not offer a local version for testing, therefore we need to use a cloud instance also for testing.

To configure the Firestore instance, copy the `.env.example` file into a `.env` file and add the parameters of your instance.

Moreover, you should configure your instance so that the documents used in the tests are actually accessible.
Something along these lines should work:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /collection/test/{document=**} {
      allow read, write: if true;
    }

    match /collection/other-test/{document=**} {
      allow read, write: if true;
    }
  }
}
```

Then run the tests using

```
npm run test
```

or

```
npm run testwatch
```

## docs

You can build the documentation of the package using

```
npm run docs
```

and then browse to

```
generated-docs/html/index.html
```

## license

Unless explicitly stated otherwise all files in this repository are licensed
under the [Hippocratic License](https://firstdonoharm.dev/).

Copyright © 2020 [Stichting Statebox](https://statebox.nl).
