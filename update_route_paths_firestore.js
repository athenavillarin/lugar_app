const admin = require('firebase-admin');
const fs = require('fs');

// Load service account key
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

// Load split route paths
const splitPaths = JSON.parse(fs.readFileSync('split_route_paths.json', 'utf-8'));

async function updateRoutes() {
  for (const [routeId, coords] of Object.entries(splitPaths)) {
    try {
      const docRef = db.collection('routes').doc(routeId);
      await docRef.update({ route_path: coords });
      console.log(`Updated ${routeId} with ${coords.length} coordinates.`);
    } catch (err) {
      console.error(`Failed to update ${routeId}:`, err.message);
    }
  }
  console.log('✓ All route paths updated in Firestore.');
  process.exit(0);
}

updateRoutes();
