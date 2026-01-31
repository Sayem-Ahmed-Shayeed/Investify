const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
// The service account file should be downloaded from Firebase Console
// and placed in the backend folder (DO NOT commit this file to git!)
const serviceAccountPath = path.join(__dirname, '../../firebase-service-account.json');

try {
  admin.initializeApp({
    credential: admin.credential.cert(require(serviceAccountPath)),
    projectId: process.env.FIREBASE_PROJECT_ID
  });
  console.log('✅ Firebase Admin SDK initialized');
} catch (error) {
  console.error('❌ Firebase Admin SDK initialization failed:', error.message);
  console.log('📝 Please download your Firebase service account key and save it as firebase-service-account.json');
}

/**
 * Middleware to verify Firebase ID tokens
 * This ensures only authenticated users from your app can access the API
 */
const verifyFirebaseToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const idToken = authHeader.split('Bearer ')[1];

  try {
    // Verify the ID token with Firebase
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Attach user info to request
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified
    };
    
    next();
  } catch (error) {
    console.error('Token verification failed:', error.message);
    
    if (error.code === 'auth/id-token-expired') {
      return res.status(401).json({ error: 'Token expired. Please re-authenticate.' });
    }
    
    return res.status(401).json({ error: 'Invalid token' });
  }
};

module.exports = { verifyFirebaseToken, admin };
