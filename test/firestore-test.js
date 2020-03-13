const Firestore = require('../output/Web.Firestore')

const app = Firestore.initializeApp({projectId: "def"})()

console.log(Firestore.firestore(app))