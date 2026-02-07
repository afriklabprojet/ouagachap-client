import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service de géocodage pour convertir coordonnées <-> adresse
class GeocodingService {
  // Utiliser Nominatim (OpenStreetMap) - gratuit et sans clé API
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  /// Convertit des coordonnées en adresse (reverse geocoding)
  Future<GeocodingResult?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'OuagaChap/1.0',
          'Accept-Language': 'fr',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GeocodingResult.fromNominatim(data);
      }
      return null;
    } catch (e) {
      print('Erreur géocodage inverse: $e');
      return null;
    }
  }

  /// Recherche d'adresse par texte (geocoding)
  Future<List<GeocodingResult>> searchAddress(String query) async {
    try {
      // Ajouter Ouagadougou pour limiter les résultats
      final searchQuery = '$query, Ouagadougou, Burkina Faso';
      final url = Uri.parse(
        '$_nominatimBaseUrl/search?format=json&q=${Uri.encodeComponent(searchQuery)}&addressdetails=1&limit=5',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'OuagaChap/1.0',
          'Accept-Language': 'fr',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => GeocodingResult.fromNominatim(item)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur recherche adresse: $e');
      return [];
    }
  }
}

/// Résultat de géocodage
class GeocodingResult {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? street;
  final String? neighbourhood;
  final String? suburb;
  final String? city;
  final String? country;

  GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.street,
    this.neighbourhood,
    this.suburb,
    this.city,
    this.country,
  });

  factory GeocodingResult.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    return GeocodingResult(
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? '',
      street: address?['road'] ?? address?['street'],
      neighbourhood: address?['neighbourhood'] ?? address?['quarter'],
      suburb: address?['suburb'] ?? address?['village'],
      city: address?['city'] ?? address?['town'] ?? 'Ouagadougou',
      country: address?['country'] ?? 'Burkina Faso',
    );
  }

  /// Adresse courte et lisible
  String get shortAddress {
    final parts = <String>[];
    if (neighbourhood != null) parts.add(neighbourhood!);
    if (suburb != null && suburb != neighbourhood) parts.add(suburb!);
    if (street != null) parts.add(street!);
    
    if (parts.isEmpty) {
      // Extraire les premiers éléments du displayName
      final displayParts = displayName.split(',');
      return displayParts.take(2).join(', ').trim();
    }
    
    return parts.join(', ');
  }
}
