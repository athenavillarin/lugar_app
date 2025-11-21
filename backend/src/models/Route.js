// Route model placeholder
class RouteModel {
  constructor(id, name, stops = []) {
    this.id = id;
    this.name = name;
    this.stops = stops;
  }
}

module.exports = RouteModel;
