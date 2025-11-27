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
    // Search without biasing since OSM data is already for Iloilo
    Future<List<NominatimPlace>> doSearch(String q) async {
      final url = Uri.parse(
        'https://a5fd03e26b68.ngrok-free.app/search?q=${Uri.encodeComponent(q)}&format=json',
      );
      print('DEBUG: NominatimService.searchPlaces url = $url');
      final response = await http
          .get(url, headers: {'User-Agent': 'lugar_app_school_project/1.0'})
          .timeout(Duration(seconds: 5));
      print(
        'DEBUG: NominatimService.searchPlaces status = ${response.statusCode}',
      );
      print('DEBUG: NominatimService.searchPlaces raw body = ${response.body}');
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print(
          'DEBUG: NominatimService.searchPlaces parsed count = [32m${data.length}[0m',
        );
        final results = data.map((e) => NominatimPlace.fromJson(e)).toList();
        for (var place in results) {
          print(
            'DEBUG: Parsed place: ${place.displayName} (${place.lat}, ${place.lon})',
          );
        }
        return results;
      } else {
        print('DEBUG: NominatimService.searchPlaces failed');
        return [];
      }
    }

    // Try the full query first
    List<NominatimPlace> results = await doSearch(query);
    if (results.isNotEmpty) return results;

    // If no results, try a simplified query by removing address parts from the end
    List<String> parts = query.split(',');
    while (parts.length > 1) {
      parts.removeLast();
      String simplified = parts.join(',').trim();
      print(
        'DEBUG: NominatimService.searchPlaces fallback query = "$simplified"',
      );
      results = await doSearch(simplified);
      if (results.isNotEmpty) return results;
    }

    // As a last resort, try just the first part (e.g., school name)
    if (parts.isNotEmpty) {
      String fallback = parts.first.trim();
      print(
        'DEBUG: NominatimService.searchPlaces final fallback query = "$fallback"',
      );
      results = await doSearch(fallback);
      if (results.isNotEmpty) return results;
    }

    // No results found
    print('DEBUG: NominatimService.searchPlaces: all fallbacks failed');
    return [];
  }

  static Future<NominatimPlace?> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://a5fd03e26b68.ngrok-free.app/reverse?lat=$lat&lon=$lon&format=json',
    );
    print('DEBUG: NominatimService.reverseGeocode url = $url');
    try {
      final response = await http
          .get(url, headers: {'User-Agent': 'lugar_app_school_project/1.0'})
          .timeout(Duration(seconds: 5));
      print(
        'DEBUG: NominatimService.reverseGeocode status = ${response.statusCode}',
      );
      print(
        'DEBUG: NominatimService.reverseGeocode raw body = ${response.body}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('display_name')) {
          print('DEBUG: NominatimService.reverseGeocode parsed place');
          return NominatimPlace.fromJson(data);
        }
      }
    } catch (e) {
      print('DEBUG: NominatimService.reverseGeocode error: $e');
    }
    print('DEBUG: NominatimService.reverseGeocode failed');
    return null;
  }
}
