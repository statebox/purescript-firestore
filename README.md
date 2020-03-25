# purescript-firestore

A Purescript library to interact with [Google Cloud Firestore](https://firebase.google.com/docs/firestore/).

The library is a work in progress and for the moment it exposes only a subset of the actual Firestore API.
Basically at the moment you can read, write and delete a single document.
Please take a look at the test in `test/Web/FirestoreSpec.purs` to see how to use the provided functions.

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

and the browse to

```
generated-docs/html/index.html
```
