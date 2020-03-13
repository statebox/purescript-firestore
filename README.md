# purescript-firestore

A Purescript library to interact with [Google Cloud Firestore](https://firebase.google.com/docs/firestore/).

The library is a work in progress and for the moment it exposes only a subset of the actual Firestore API.

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
