const fs = require('fs');
const { parseString } = require('xml2js');

// Parse KML and extract coordinates
function parseKML(kmlFile) {
  const kmlContent = fs.readFileSync(kmlFile, 'utf-8');
  
  return new Promise((resolve, reject) => {
    parseString(kmlContent, (err, result) => {
      if (err) {
        reject(err);
        return;
      }

      try {
        const allCoordinates = [];
        
        // Try to find Placemarks - check all Folders and Document
        let placemarks = [];
        
        // Check all Folders for Placemarks
        if (result.kml.Document[0].Folder) {
          result.kml.Document[0].Folder.forEach(folder => {
            if (folder.Placemark) {
              placemarks = placemarks.concat(folder.Placemark);
            }
          });
        }
        
        // Also check direct Placemarks in Document
        if (result.kml.Document[0].Placemark) {
          placemarks = placemarks.concat(result.kml.Document[0].Placemark);
        }

        placemarks.forEach(placemark => {
          if (placemark.LineString && placemark.LineString[0].coordinates) {
            const coordText = placemark.LineString[0].coordinates[0].trim();
            const coords = coordText.split('\n')
              .map(line => line.trim())
              .filter(line => line.length > 0)
              .map(line => {
                const parts = line.split(',');
                return {
                  longitude: parseFloat(parts[0]),
                  latitude: parseFloat(parts[1])
                };
              });
            allCoordinates.push(...coords);
          }
        });

        resolve(allCoordinates);
      } catch (error) {
        reject(error);
      }
    });
  });
}

// Process all KML files
async function processKMLFiles() {
  const kmlFiles = fs.readdirSync('.')
    .filter(file => file.endsWith('.kml'))
    .sort();

  console.log(`Found ${kmlFiles.length} KML files\n`);

  const routePaths = {};

  for (const kmlFile of kmlFiles) {
    try {
      const routeId = kmlFile.replace('.kml', '');
      console.log(`Processing ${kmlFile}...`);
      
      const coordinates = await parseKML(kmlFile);
      console.log(`  - Extracted ${coordinates.length} coordinates`);
      
      // For routes with A/B variants, we'll need to split
      // For now, store the full path
      routePaths[routeId] = coordinates;
      
      // Find midpoint for potential A/B split
      const midpoint = Math.floor(coordinates.length / 2);
      console.log(`  - Midpoint at index: ${midpoint}`);
      console.log(`  - First coord: ${coordinates[0].latitude}, ${coordinates[0].longitude}`);
      console.log(`  - Mid coord: ${coordinates[midpoint].latitude}, ${coordinates[midpoint].longitude}`);
      console.log(`  - Last coord: ${coordinates[coordinates.length-1].latitude}, ${coordinates[coordinates.length-1].longitude}\n`);

    } catch (error) {
      console.error(`Error processing ${kmlFile}:`, error.message);
    }
  }

  // Save to JSON for review
  fs.writeFileSync('route_paths.json', JSON.stringify(routePaths, null, 2));
  console.log('✓ Saved all route paths to route_paths.json');
  
  return routePaths;
}

processKMLFiles().then(() => {
  console.log('\n✓ Done! Review route_paths.json to see the coordinates.');
  console.log('Next: Determine which routes need A/B splitting and update the script.');
});
