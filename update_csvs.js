const fs = require('fs');
const csv = require('csv-parser');

// Update route_stops.csv
const routeStops = [];
fs.createReadStream('route_stops.csv')
  .pipe(csv())
  .on('data', (row) => {
    if (row.route_id && row.stop_id && row.order) {
      routeStops.push({
        route_stop_id: `${row.route_id}_${row.stop_id}_${row.order}`,
        route_id: row.route_id,
        stop_id: row.stop_id,
        order: row.order
      });
    }
  })
  .on('end', () => {
    const header = 'route_stop_id,route_id,stop_id,order\n';
    const content = routeStops.map(r => 
      `${r.route_stop_id},${r.route_id},${r.stop_id},${r.order}`
    ).join('\n');
    fs.writeFileSync('route_stops.csv', header + content);
    console.log('✓ route_stops.csv updated');
  });

// Update fares.csv
setTimeout(() => {
  const fares = [];
  fs.createReadStream('fares.csv')
    .pipe(csv())
    .on('data', (row) => {
      if (row.fare_id && row.distance_km) {
        fares.push({
          fare_id: `${row.fare_id}_${row.distance_km}`,
          fare_type: row.fare_id,
          distance_km: row.distance_km,
          regular: row.regular,
          discounted: row.discounted
        });
      }
    })
    .on('end', () => {
      const header = 'fare_id,fare_type,distance_km,regular,discounted\n';
      const content = fares.map(f => 
        `${f.fare_id},${f.fare_type},${f.distance_km},${f.regular},${f.discounted}`
      ).join('\n');
      fs.writeFileSync('fares.csv', header + content);
      console.log('✓ fares.csv updated');
    });
}, 1000);
