import '../models/location_suggestion.dart';

// Temporary location data for Iloilo City
class TempLocations {
  static List<LocationSuggestion> searchLocations(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _iiloiloLocations
        .where(
          (location) =>
              location.name.toLowerCase().contains(lowerQuery) ||
              location.address.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  static const List<LocationSuggestion> _iiloiloLocations = [
    // Jaro area
    LocationSuggestion(
      name: 'Jaro Plaza',
      address: 'Plaza Rizal Street, Jaro, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Jaro National High School',
      address: 'Fajardo Street, Jaro, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Jaro Big Market',
      address: 'El 98 Street, Jaro, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Jaro Cathedral',
      address: 'López Jaena Street, Jaro, Iloilo City, Iloilo',
    ),

    // Molo area
    LocationSuggestion(
      name: 'Molo Church',
      address: 'J.M. Basa Street, Molo, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Molo Plaza',
      address: 'Molo Plaza, Molo, Iloilo City, Iloilo',
    ),

    // City Proper
    LocationSuggestion(
      name: 'Iloilo City Hall',
      address: 'Bonifacio Drive, City Proper, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'SM City Iloilo',
      address: 'Benigno Aquino Avenue, Mandurriao, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Robinsons Place Iloilo',
      address: 'General Luna Street, City Proper, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Iloilo Esplanade',
      address: 'Muelle Loney Street, City Proper, Iloilo City, Iloilo',
    ),

    // Mandurriao
    LocationSuggestion(
      name: 'Iloilo International Airport',
      address: 'Airport Road, Cabatuan, Iloilo',
    ),
    LocationSuggestion(
      name: 'University of the Philippines Visayas',
      address: 'Miagao, Iloilo',
    ),

    // Pavia
    LocationSuggestion(
      name: 'Robinsons Place Pavia',
      address: 'Pavia-Leganes Road, Pavia, Iloilo',
    ),

    // La Paz
    LocationSuggestion(
      name: 'La Paz Public Market',
      address: 'La Paz, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Ted\'s Oldtimer La Paz Batchoy',
      address: 'La Paz, Iloilo City, Iloilo',
    ),

    // Arevalo
    LocationSuggestion(
      name: 'Arevalo Plaza',
      address: 'Arevalo, Iloilo City, Iloilo',
    ),

    // Mandurriao
    LocationSuggestion(
      name: 'West Visayas State University',
      address: 'Luna Street, La Paz, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Central Philippine University',
      address: 'Lopez Jaena Street, Jaro, Iloilo City, Iloilo',
    ),

    // Additional landmarks
    LocationSuggestion(
      name: 'Gaisano City Mall',
      address: 'General Luna Street, City Proper, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Iloilo Provincial Capitol',
      address: 'Bonifacio Drive, City Proper, Iloilo City, Iloilo',
    ),
    LocationSuggestion(
      name: 'Festive Walk Mall',
      address: 'Megaworld Boulevard, Mandurriao, Iloilo City, Iloilo',
    ),
  ];
}
