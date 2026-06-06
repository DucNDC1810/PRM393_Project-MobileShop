const admin = require('firebase-admin');
const serviceAccount = require('../seed/serviceAccountKey.json.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function checkDb() {
  try {
    const productsSnap = await db.collection('products').get();
    console.log(`Firestore has ${productsSnap.size} products.`);
    productsSnap.docs.slice(0, 3).forEach(doc => {
      console.log(`- Product ID: ${doc.id}, Name: ${doc.data().name}, Category: ${doc.data().category}, Active: ${doc.data().is_active}`);
    });

    const categoriesSnap = await db.collection('categories').get();
    console.log(`Firestore has ${categoriesSnap.size} categories.`);
    categoriesSnap.docs.forEach(doc => {
      console.log(`- Category ID: ${doc.id}, Name: ${doc.data().name}, Slug: ${doc.data().slug}`);
    });
  } catch (error) {
    console.error('Error connecting to Firestore:', error);
  } finally {
    process.exit(0);
  }
}

checkDb();
