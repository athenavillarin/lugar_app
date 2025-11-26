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
    final String iloiloQuery = '$query, Iloilo City, Iloilo, Philippines';
    final url = Uri.parse(
      'https://234a85c9f700.ngrok-free.app/search?q=${Uri.encodeComponent(iloiloQuery)}&format=json',
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
