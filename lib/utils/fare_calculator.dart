// Fare calculation helpers
import '../models/fare.dart';

class FareCalculator {
  static Fare calculateFare(double distanceKm) {
    // simple placeholder calculation
    final amount = 10 + distanceKm * 2;
    return Fare(amount: amount);
  }
}
