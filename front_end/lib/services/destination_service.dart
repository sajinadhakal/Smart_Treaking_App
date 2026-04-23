import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/destination.dart';
import '../models/trek_route.dart';
import '../models/weather.dart';
import 'auth_service.dart';

class DestinationPageResponse {
  final List<Destination> destinations;
  final int count;
  final String? next;
  final String? previous;

  const DestinationPageResponse({
    required this.destinations,
    required this.count,
    this.next,
    this.previous,
  });
}

class DestinationService {
  final AuthService _authService = AuthService();

  static const Set<String> _localOnlyHosts = {
    '127.0.0.1',
    'localhost',
    '10.0.2.2',
  };

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await _authService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, dynamic> _normalizeDestinationJson(dynamic raw) {
    final json = Map<String, dynamic>.from(raw as Map);
    final image = json['image']?.toString();
    if (image != null && image.isNotEmpty && !image.startsWith('http')) {
      json['image'] = '${ApiConfig.baseUrl.replaceAll('/api', '')}/media/$image';
    }
    return json;
  }

  String _normalizePageUrlForCurrentDevice(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme) {
      return rawUrl;
    }

    if (_localOnlyHosts.contains(uri.host)) {
      final base = Uri.parse(ApiConfig.baseUrl);
      return base
          .replace(
            path: uri.path,
            query: uri.query,
          )
          .toString();
    }

    return rawUrl;
  }

  DestinationPageResponse _parseDestinationPage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final dynamic rawResults = decoded['results'] ?? const <dynamic>[];
      final List<Destination> parsed = (rawResults as List)
          .map((item) => Destination.fromJson(_normalizeDestinationJson(item)))
          .toList();

      return DestinationPageResponse(
        destinations: parsed,
        count: (decoded['count'] as num?)?.toInt() ?? parsed.length,
        next: decoded['next']?.toString(),
        previous: decoded['previous']?.toString(),
      );
    }

    if (decoded is List) {
      final parsed = decoded
          .map((item) => Destination.fromJson(_normalizeDestinationJson(item)))
          .toList();

      return DestinationPageResponse(
        destinations: parsed,
        count: parsed.length,
      );
    }

    return const DestinationPageResponse(destinations: [], count: 0);
  }

  Future<DestinationPageResponse> getDestinationsPage({
    String? search,
    String? ordering,
    int page = 1,
    String? pageUrl,
  }) async {
    try {
      String url;
      if (pageUrl != null && pageUrl.isNotEmpty) {
        url = _normalizePageUrlForCurrentDevice(pageUrl);
      } else {
        url = ApiConfig.destinations;
        final queryParams = <String>[];
        if (search != null && search.isNotEmpty) {
          queryParams.add('search=${Uri.encodeQueryComponent(search)}');
        }
        if (ordering != null && ordering.isNotEmpty) {
          queryParams.add('ordering=${Uri.encodeQueryComponent(ordering)}');
        }
        queryParams.add('page=$page');
        url += '?${queryParams.join('&')}';
      }

      print('Destination API GET: $url');
      print('Destination API baseUrl: ${ApiConfig.baseUrl}');
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(includeAuth: false),
      );

      print('Destination API status: ${response.statusCode}');
      print('Destination API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseDestinationPage(data);
      }

      throw Exception('Failed to fetch destinations (${response.statusCode})');
    } catch (e) {
      print('Error fetching destinations: $e');
      rethrow;
    }
  }

  Future<List<Destination>> getDestinations({String? search, String? ordering}) async {
    try {
      final page = await getDestinationsPage(
        search: search,
        ordering: ordering,
        page: 1,
      );
      return page.destinations;
    } catch (e) {
      print('Error fetching destination list: $e');
      return [];
    }
  }

  Future<Destination?> getDestinationDetail(int id) async {

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.destinationDetail(id)),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        final dest = Destination.fromJson(
          _normalizeDestinationJson(jsonDecode(response.body)),
        );

        return dest;
      }
      return null;
    } catch (e) {
      print('Error fetching destination detail: $e');
      return null;
    }
  }

  Future<List<TrekRoute>> getDestinationRoute(int id) async {

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.destinationRoute(id)),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => TrekRoute.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching route: $e');
      return [];
    }
  }

  Future<Weather?> getDestinationWeather(int id) async {

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.destinationWeather(id)),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  Future<List<Destination>> getFeaturedDestinations() async {

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.destinations}featured/'),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final destinations = data
            .map((json) => Destination.fromJson(_normalizeDestinationJson(json)))
            .toList();

        return destinations;
      }
      return [];
    } catch (e) {
      print('Error fetching featured destinations: $e');
      return [];
    }
  }
}
