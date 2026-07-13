const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function createAdmin() {
  try {
    const email = 'admin@admin.com';
    const password = '123456';
    
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(email);
      console.log('User already exists, updating password and emailVerified...');
      await auth.updateUser(userRecord.uid, { password, emailVerified: true });
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        userRecord = await auth.createUser({
          email: email,
          password: password,
          displayName: 'Admin',
          emailVerified: true,
        });
        console.log('Successfully created new user:', userRecord.uid);
      } else {
        throw error;
      }
    }

    // Set custom claims if needed
    await auth.setCustomUserClaims(userRecord.uid, { admin: true });

    // Save to firestore users collection with role: 'admin'
    await db.collection('users').doc(userRecord.uid).set({
      email: email,
      name: 'Admin',
      role: 'admin',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    console.log('Admin user created/updated successfully in Auth and Firestore!');
    console.log('Email:', email);
    console.log('Password:', password);
    process.exit(0);
  } catch (error) {
    console.error('Error creating admin:', error);
    process.exit(1);
  }
}

createAdmin();
