// Route model
import 'stop.dart';

class RouteModel {
  final String id;
  final String name;
  final List<Stop> stops;

  RouteModel({required this.id, required this.name, required this.stops});
}
