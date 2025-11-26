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

// Sample fare data (replace with your actual fares)
// Assuming fares are per route, with regular and discounted prices
const faresData = {
  'R001A': { regular: 10.0, discounted: 8.0 },
  'R001B': { regular: 10.0, discounted: 8.0 },
  'R002A': { regular: 12.0, discounted: 9.0 },
  'R002B': { regular: 12.0, discounted: 9.0 },
  // Add more routes as needed
};

async function updateFares() {
  for (const [routeId, fares] of Object.entries(faresData)) {
    try {
      const docRef = db.collection('fares').doc(routeId);
      await docRef.set({
        route_id: routeId,
        regular: fares.regular,
        discounted: fares.discounted
      });
      console.log(`Updated fares for ${routeId}: regular ${fares.regular}, discounted ${fares.discounted}`);
    } catch (err) {
      console.error(`Failed to update fares for ${routeId}:`, err.message);
    }
  }
  console.log('✓ All fares updated in Firestore.');
  process.exit(0);
}

updateFares();