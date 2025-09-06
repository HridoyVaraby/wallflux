import 'dart:io';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper.dart';
import 'local_storage_service.dart';

enum WallpaperLocation {
  homeScreen,
  lockScreen,
  bothScreens,
}

class WallpaperService {
  static WallpaperService? _instance;
  static WallpaperService get instance => _instance ??= WallpaperService._();
  
  WallpaperService._();

  final LocalStorageService _localStorage = LocalStorageService.instance;

  /// Set wallpaper from a Wallpaper model
  Future<bool> setWallpaper(
    Wallpaper wallpaper, {
    WallpaperLocation location = WallpaperLocation.bothScreens,
  }) async {
    try {
      // Download the image
      final imageFile = await _downloadImage(wallpaper.urls.regular, wallpaper.id);
      if (imageFile == null) {
        throw WallpaperException('Failed to download wallpaper image');
      }

      // Set the wallpaper
      final success = await _setWallpaperFromFile(imageFile, location);
      
      if (success) {
        // Save wallpaper info and update current wallpaper
        await _localStorage.saveWallpaper(wallpaper);
        await _localStorage.setCurrentWallpaper(wallpaper.id);
      }

      return success;
    } catch (e) {
      throw WallpaperException('Failed to set wallpaper: $e');
    }
  }

  /// Set wallpaper from URL
  Future<bool> setWallpaperFromUrl(
    String imageUrl, 
    String wallpaperId, {
    WallpaperLocation location = WallpaperLocation.bothScreens,
  }) async {
    try {
      final imageFile = await _downloadImage(imageUrl, wallpaperId);
      if (imageFile == null) {
        throw WallpaperException('Failed to download image from URL');
      }

      final success = await _setWallpaperFromFile(imageFile, location);
      
      if (success) {
        await _localStorage.setCurrentWallpaper(wallpaperId);
      }

      return success;
    } catch (e) {
      throw WallpaperException('Failed to set wallpaper from URL: $e');
    }
  }

  /// Set wallpaper from local file
  Future<bool> setWallpaperFromFile(
    File imageFile, {
    WallpaperLocation location = WallpaperLocation.bothScreens,
  }) async {
    try {
      return await _setWallpaperFromFile(imageFile, location);
    } catch (e) {
      throw WallpaperException('Failed to set wallpaper from file: $e');
    }
  }

  /// Internal method to set wallpaper from file
  Future<bool> _setWallpaperFromFile(
    File imageFile, 
    WallpaperLocation location,
  ) async {
    try {
      int wallpaperLocation;
      
      switch (location) {
        case WallpaperLocation.homeScreen:
          wallpaperLocation = WallpaperManager.HOME_SCREEN;
          break;
        case WallpaperLocation.lockScreen:
          wallpaperLocation = WallpaperManager.LOCK_SCREEN;
          break;
        case WallpaperLocation.bothScreens:
          wallpaperLocation = WallpaperManager.BOTH_SCREEN;
          break;
      }

      final result = await WallpaperManager.setWallpaperFromFile(
        imageFile.path,
        wallpaperLocation,
      );

      return result;
    } catch (e) {
      throw WallpaperException('Failed to apply wallpaper: $e');
    }
  }

  /// Download image and save to temporary directory
  Future<File?> _downloadImage(String imageUrl, String wallpaperId) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode != 200) {
        throw WallpaperException('Failed to download image: HTTP ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/wallpaper_$wallpaperId.jpg');
      
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Get current wallpaper info
  Future<Wallpaper?> getCurrentWallpaper() async {
    return await _localStorage.getCurrentWallpaper();
  }

  /// Set random wallpaper from favorites
  Future<bool> setRandomFavoriteWallpaper({
    WallpaperLocation location = WallpaperLocation.bothScreens,
  }) async {
    try {
      final favorites = await _localStorage.getFavoriteWallpapers();
      
      if (favorites.isEmpty) {
        throw WallpaperException('No favorite wallpapers found');
      }

      // Select random favorite
      favorites.shuffle();
      final randomWallpaper = favorites.first;
      
      return await setWallpaper(randomWallpaper, location: location);
    } catch (e) {
      throw WallpaperException('Failed to set random favorite wallpaper: $e');
    }
  }

  /// Set random wallpaper from cached wallpapers
  Future<bool> setRandomCachedWallpaper({
    WallpaperLocation location = WallpaperLocation.bothScreens,
  }) async {
    try {
      final cached = await _localStorage.getCachedWallpapers(limit: 50);
      
      if (cached.isEmpty) {
        throw WallpaperException('No cached wallpapers found');
      }

      // Select random cached wallpaper
      cached.shuffle();
      final randomWallpaper = cached.first;
      
      return await setWallpaper(randomWallpaper, location: location);
    } catch (e) {
      throw WallpaperException('Failed to set random cached wallpaper: $e');
    }
  }

  /// Clean up temporary wallpaper files
  Future<void> cleanupTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('wallpaper_')) {
          try {
            await file.delete();
          } catch (e) {
            // Ignore errors when deleting temporary files
            print('Error deleting temporary file: $e');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temporary files: $e');
    }
  }

  /// Get wallpaper cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      final wallpaperFiles = files.where((file) => 
          file is File && file.path.contains('wallpaper_')).toList();
      
      int totalSize = 0;
      for (final file in wallpaperFiles) {
        if (file is File) {
          try {
            final stat = await file.stat();
            totalSize += stat.size;
          } catch (e) {
            // Ignore errors
          }
        }
      }

      return {
        'fileCount': wallpaperFiles.length,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      return {
        'fileCount': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
      };
    }
  }

  /// Check if wallpaper setting is supported
  Future<bool> isWallpaperSupported() async {
    try {
      // This is a simple check - in a real app you might want more sophisticated detection
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }
}

class WallpaperException implements Exception {
  final String message;
  
  WallpaperException(this.message);
  
  @override
  String toString() => 'WallpaperException: $message';
}