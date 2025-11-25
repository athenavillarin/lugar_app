import 'dart:convert';
import 'package:http/http.dart' as http;

class NominatimPlace {
  final String displayName;
  final double lat;
  final double lon;

  NominatimPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'],
      lat: double.tryParse(json['lat'] ?? '') ?? 0.0,
      lon: double.tryParse(json['lon'] ?? '') ?? 0.0,
    );
  }
}

class NominatimService {
  static Future<List<NominatimPlace>> searchPlaces(String query) async {
    // Always bias search to Iloilo City, Iloilo, Philippines
    final String iloiloQuery = '$query, Iloilo City, Iloilo, Philippines';
    // Optionally, use a viewbox to further restrict results to Iloilo area
    // Viewbox: left,top,right,bottom (approximate bounds for Iloilo City)
    final String viewbox = '122.515,10.745,122.605,10.675';
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(iloiloQuery)}&format=json&addressdetails=1&limit=10&viewbox=$viewbox&bounded=1&email=your@email.com',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'lugar_app_school_project/1.0'},
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => NominatimPlace.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
