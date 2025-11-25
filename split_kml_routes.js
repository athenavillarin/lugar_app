const fs = require('fs');
const { parse } = require('csv-parse/sync');
const { parseString } = require('xml2js');

// Helper: Haversine distance
function haversine(lat1, lon1, lat2, lon2) {
  const toRad = deg => deg * Math.PI / 180;
  const R = 6371e3;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat/2)**2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}

// Load stops.csv
const stopsCsv = fs.readFileSync('stops.csv', 'utf-8');
const stops = {};
parse(stopsCsv, { columns: true, skip_empty_lines: true }).forEach(row => {
  stops[row.stop_id] = {
    name: row.stop_name.replace(/\"/g, ''),
    latitude: parseFloat(row.latitude),
    longitude: parseFloat(row.longitude)
  };
});

// Load route_stops.csv
const routeStopsCsv = fs.readFileSync('route_stops.csv', 'utf-8');
const routeStops = {};
parse(routeStopsCsv, { columns: true, skip_empty_lines: true }).forEach(row => {
  if (!routeStops[row.route_id]) routeStops[row.route_id] = [];
  routeStops[row.route_id][parseInt(row.order)-1] = row.stop_id;
});

// Load KML coordinates
function parseKMLCoords(kmlFile) {
  const kmlContent = fs.readFileSync(kmlFile, 'utf-8');
  return new Promise((resolve, reject) => {
    parseString(kmlContent, (err, result) => {
      if (err) return reject(err);
      let placemarks = [];
      if (result.kml.Document[0].Folder) {
        result.kml.Document[0].Folder.forEach(folder => {
          if (folder.Placemark) placemarks = placemarks.concat(folder.Placemark);
        });
      }
      if (result.kml.Document[0].Placemark) {
        placemarks = placemarks.concat(result.kml.Document[0].Placemark);
      }
      // Only use LineString coordinates
      let coords = [];
      placemarks.forEach(pm => {
        if (pm.LineString && pm.LineString[0].coordinates) {
          const lines = pm.LineString[0].coordinates[0].trim().split(/\s+/);
          lines.forEach(line => {
            const [lon, lat] = line.split(',').map(Number);
            coords.push({ latitude: lat, longitude: lon });
          });
        }
      });
      resolve(coords);
    });
  });
}

// Find closest index in coords to a stop
function findClosestIndex(coords, stop) {
  let minDist = Infinity, minIdx = 0;
  coords.forEach((c, i) => {
    const d = haversine(stop.latitude, stop.longitude, c.latitude, c.longitude);
    if (d < minDist) {
      minDist = d;
      minIdx = i;
    }
  });
  return minIdx;
}

(async () => {
  const kmlFiles = fs.readdirSync('.')
    .filter(f => f.endsWith('.kml'));
  const splitPaths = {};
  for (const kmlFile of kmlFiles) {
    const routeBase = kmlFile.replace('.kml', '');
    // Find A and B variants
    const aId = routeBase + 'A';
    const bId = routeBase + 'B';
    if (!routeStops[aId] || !routeStops[bId]) continue;
    const coords = await parseKMLCoords(kmlFile);
    // Find start/end indices for A and B
    const aStart = findClosestIndex(coords, stops[routeStops[aId][0]]);
    const aEnd = findClosestIndex(coords, stops[routeStops[aId][routeStops[aId].length-1]]);
    const bStart = findClosestIndex(coords, stops[routeStops[bId][0]]);
    const bEnd = findClosestIndex(coords, stops[routeStops[bId][routeStops[bId].length-1]]);
    // Assume A is forward, B is reverse (may need adjustment)
    splitPaths[aId] = coords.slice(Math.min(aStart, aEnd), Math.max(aStart, aEnd)+1);
    splitPaths[bId] = coords.slice(Math.min(bStart, bEnd), Math.max(bStart, bEnd)+1).reverse();
    console.log(`${kmlFile}: ${aId} [${splitPaths[aId].length}] | ${bId} [${splitPaths[bId].length}]`);
  }
  fs.writeFileSync('split_route_paths.json', JSON.stringify(splitPaths, null, 2));
  console.log('✓ Saved split paths to split_route_paths.json');
})();
