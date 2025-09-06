import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';
import '../models/unsplash_response.dart';

class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  
  // Note: In a production app, this should be stored securely
  // For demo purposes, using a public demo access key
  static const String _accessKey = 'YOUR_UNSPLASH_ACCESS_KEY';
  
  // Alternative: Use demo photos endpoint (doesn't require API key)
  static const bool _useDemoMode = true;
  
  final http.Client _client;
  
  UnsplashService({http.Client? client}) : _client = client ?? http.Client();

  /// Search wallpapers by query with pagination
  Future<UnsplashSearchResponse> searchWallpapers({
    required String query,
    int page = 1,
    int perPage = 30,
    String orientation = 'portrait',
  }) async {
    if (_useDemoMode) {
      return _generateDemoSearchResponse(query, page, perPage);
    }

    try {
      final uri = Uri.parse('$_baseUrl/search/photos').replace(
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'per_page': perPage.toString(),
          'orientation': orientation,
          'client_id': _accessKey,
        },
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UnsplashSearchResponse.fromJson(jsonData);
      } else {
        throw UnsplashException('Failed to fetch wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnsplashException) rethrow;
      throw UnsplashException('Network error: $e');
    }
  }

  /// Get random wallpapers from multiple categories
  Future<List<Wallpaper>> getRandomWallpapers({
    List<String> categories = const [],
    int count = 30,
    String orientation = 'portrait',
  }) async {
    if (_useDemoMode) {
      return _generateDemoWallpapers(count, categories);
    }

    try {
      final uri = Uri.parse('$_baseUrl/photos/random').replace(
        queryParameters: {
          'count': count.toString(),
          'orientation': orientation,
          if (categories.isNotEmpty) 'topics': categories.join(','),
          'client_id': _accessKey,
        },
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> wallpaperList = jsonData is List ? jsonData : [jsonData];
        return wallpaperList.map((json) => Wallpaper.fromJson(json)).toList();
      } else {
        throw UnsplashException('Failed to fetch random wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnsplashException) rethrow;
      throw UnsplashException('Network error: $e');
    }
  }

  /// Get wallpapers by category/collection
  Future<List<Wallpaper>> getWallpapersByCategory({
    required String category,
    int page = 1,
    int perPage = 30,
    String orientation = 'portrait',
  }) async {
    return searchWallpapers(
      query: category,
      page: page,
      perPage: perPage,
      orientation: orientation,
    ).then((response) => response.results);
  }

  /// Get featured wallpapers (curated)
  Future<List<Wallpaper>> getFeaturedWallpapers({
    int page = 1,
    int perPage = 30,
    String orientation = 'portrait',
  }) async {
    if (_useDemoMode) {
      return _generateDemoWallpapers(perPage, ['featured']);
    }

    try {
      final uri = Uri.parse('$_baseUrl/photos').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
          'order_by': 'popular',
          'client_id': _accessKey,
        },
      );

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Client-ID $_accessKey',
          'Accept-Version': 'v1',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> wallpaperList = jsonData;
        return wallpaperList.map((json) => Wallpaper.fromJson(json)).toList();
      } else {
        throw UnsplashException('Failed to fetch featured wallpapers: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnsplashException) rethrow;
      throw UnsplashException('Network error: $e');
    }
  }

  void dispose() {
    _client.close();
  }

  // Demo mode methods for development/testing
  UnsplashSearchResponse _generateDemoSearchResponse(String query, int page, int perPage) {
    final wallpapers = _generateDemoWallpapers(perPage, [query]);
    return UnsplashSearchResponse(
      total: 1000,
      totalPages: (1000 / perPage).ceil(),
      results: wallpapers,
    );
  }

  List<Wallpaper> _generateDemoWallpapers(int count, List<String> categories) {
    final random = Random();
    final demoImages = [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      'https://images.unsplash.com/photo-1441974231531-c6227db76b6e',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      'https://images.unsplash.com/photo-1518837695005-2083093ee35b',
      'https://images.unsplash.com/photo-1501594907352-04cda38ebc29',
      'https://images.unsplash.com/photo-1482938289607-e9573fc25ebb',
      'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
      'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
    ];

    return List.generate(count, (index) {
      final imageUrl = demoImages[random.nextInt(demoImages.length)];
      final id = 'demo_${random.nextInt(100000)}';
      
      return Wallpaper(
        id: id,
        description: 'Beautiful ${categories.isNotEmpty ? categories.first : 'nature'} wallpaper #${index + 1}',
        altDescription: 'Demo wallpaper for development',
        urls: WallpaperUrls(
          raw: '$imageUrl?w=1920&h=1080&fit=crop',
          full: '$imageUrl?w=1920&h=1080&fit=crop',
          regular: '$imageUrl?w=1080&h=1920&fit=crop',
          small: '$imageUrl?w=400&h=600&fit=crop',
          thumb: '$imageUrl?w=200&h=300&fit=crop',
        ),
        user: WallpaperUser(
          id: 'demo_user_${random.nextInt(1000)}',
          username: 'demo_photographer_${random.nextInt(100)}',
          name: 'Demo Photographer ${random.nextInt(100)}',
          profileImage: WallpaperUserProfileImage(
            small: 'https://images.unsplash.com/profile-1446404465118-3a53b909cc82?w=32&h=32&fit=crop',
            medium: 'https://images.unsplash.com/profile-1446404465118-3a53b909cc82?w=64&h=64&fit=crop',
            large: 'https://images.unsplash.com/profile-1446404465118-3a53b909cc82?w=128&h=128&fit=crop',
          ),
        ),
        createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))).toIso8601String(),
        tags: categories.isNotEmpty ? categories : ['nature', 'landscape'],
      );
    });
  }
}

class UnsplashException implements Exception {
  final String message;
  
  UnsplashException(this.message);
  
  @override
  String toString() => 'UnsplashException: $message';
}