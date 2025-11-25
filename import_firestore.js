const admin = require('firebase-admin');
const fs = require('fs');
const csv = require('csv-parser');

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCollection(collectionName) {
  const collectionRef = db.collection(collectionName);
  const snapshot = await collectionRef.get();
  
  if (snapshot.empty) {
    console.log(`Collection ${collectionName} is already empty`);
    return;
  }

  console.log(`Deleting ${snapshot.size} documents from ${collectionName}...`);
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  console.log(`✓ ${collectionName} cleared`);
}

async function importCollection(fileName, collectionName, transform, useAutoId = false) {
  const data = [];
  
  return new Promise((resolve, reject) => {
    fs.createReadStream(fileName)
      .pipe(csv())
      .on('data', (row) => data.push(row))
      .on('end', async () => {
        console.log(`Importing ${data.length} documents to ${collectionName}...`);
        
        for (const row of data) {
          const docData = transform ? transform(row) : row;
          
          if (useAutoId) {
            // Use auto-generated ID for collections with repeating IDs
            await db.collection(collectionName).add(docData);
          } else {
            // Use first column as document ID
            const docId = row[Object.keys(row)[0]];
            await db.collection(collectionName).doc(docId).set(docData);
          }
        }
        
        console.log(`✓ ${collectionName} imported successfully`);
        resolve();
      })
      .on('error', reject);
  });
}

async function main() {
  try {
    // Delete existing data
    console.log('Clearing existing data...\n');
    await deleteCollection('routes');
    await deleteCollection('stops');
    await deleteCollection('route_stops');
    await deleteCollection('fares');
    console.log('\nStarting import...\n');

    // Import routes
    await importCollection('routes.csv', 'routes', (row) => ({
      route_name: row.route_name || '',
      jeepney_signage: row.jeepney_signage || '',
      origin: row.origin || '',
      destination: row.destination || '',
      route_path: row.route_path || '',
      approx_duration_mins: parseInt(row.approx_duration_mins) || 0
    }));

    // Import stops
    await importCollection('stops.csv', 'stops', (row) => ({
      stop_name: row.stop_name || '',
      latitude: parseFloat(row.latitude) || 0,
      longitude: parseFloat(row.longitude) || 0
    }));

    // Import route_stops (now has unique route_stop_id)
    await importCollection('route_stops.csv', 'route_stops', (row) => ({
      route_id: row.route_id || '',
      stop_id: row.stop_id || '',
      order: parseInt(row.order) || 0
    }), false);

    // Import fares (now has unique fare_id combining type and distance)
    await importCollection('fares.csv', 'fares', (row) => ({
      fare_type: row.fare_type || '',
      distance_km: parseFloat(row.distance_km) || 0,
      regular: parseFloat(row.regular) || 0,
      discounted: parseFloat(row.discounted) || 0
    }), false);

    console.log('\n✓ All data imported successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error importing data:', error);
    process.exit(1);
  }
}

main();
