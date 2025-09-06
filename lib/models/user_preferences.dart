import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 5)
class UserPreferences extends HiveObject {
  @HiveField(0)
  final List<String> selectedNiches;
  
  @HiveField(1)
  final int updateIntervalMinutes;
  
  @HiveField(2)
  final bool isAutoUpdateEnabled;
  
  @HiveField(3)
  final bool isFirstLaunch;
  
  @HiveField(4)
  final String? customUpdateTime; // Format: "HH:mm"
  
  @HiveField(5)
  final bool useCustomTime;
  
  @HiveField(6)
  final String? currentWallpaperId;
  
  @HiveField(7)
  final List<String> favoriteWallpaperIds;
  
  @HiveField(8)
  final bool rotateOnlyFavorites;
  
  @HiveField(9)
  final DateTime? lastUpdateTime;

  UserPreferences({
    this.selectedNiches = const [],
    this.updateIntervalMinutes = 360, // Default: 6 hours
    this.isAutoUpdateEnabled = true,
    this.isFirstLaunch = true,
    this.customUpdateTime,
    this.useCustomTime = false,
    this.currentWallpaperId,
    this.favoriteWallpaperIds = const [],
    this.rotateOnlyFavorites = false,
    this.lastUpdateTime,
  });

  UserPreferences copyWith({
    List<String>? selectedNiches,
    int? updateIntervalMinutes,
    bool? isAutoUpdateEnabled,
    bool? isFirstLaunch,
    String? customUpdateTime,
    bool? useCustomTime,
    String? currentWallpaperId,
    List<String>? favoriteWallpaperIds,
    bool? rotateOnlyFavorites,
    DateTime? lastUpdateTime,
  }) {
    return UserPreferences(
      selectedNiches: selectedNiches ?? this.selectedNiches,
      updateIntervalMinutes: updateIntervalMinutes ?? this.updateIntervalMinutes,
      isAutoUpdateEnabled: isAutoUpdateEnabled ?? this.isAutoUpdateEnabled,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      customUpdateTime: customUpdateTime ?? this.customUpdateTime,
      useCustomTime: useCustomTime ?? this.useCustomTime,
      currentWallpaperId: currentWallpaperId ?? this.currentWallpaperId,
      favoriteWallpaperIds: favoriteWallpaperIds ?? this.favoriteWallpaperIds,
      rotateOnlyFavorites: rotateOnlyFavorites ?? this.rotateOnlyFavorites,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }

  // Helper methods
  bool get hasSelectedNiches => selectedNiches.isNotEmpty;
  
  bool get shouldShowOnboarding => isFirstLaunch || !hasSelectedNiches;
  
  Duration get updateInterval => Duration(minutes: updateIntervalMinutes);
  
  String get updateIntervalDisplay {
    final hours = updateIntervalMinutes ~/ 60;
    final minutes = updateIntervalMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  // Predefined interval options
  static const Map<String, int> intervalPresets = {
    '1 Hour': 60,
    '2 Hours': 120,
    '4 Hours': 240,
    '6 Hours': 360,
    '12 Hours': 720,
    'Daily': 1440,
  };

  bool isFavorite(String wallpaperId) {
    return favoriteWallpaperIds.contains(wallpaperId);
  }

  UserPreferences addFavorite(String wallpaperId) {
    if (isFavorite(wallpaperId)) return this;
    
    final newFavorites = List<String>.from(favoriteWallpaperIds)..add(wallpaperId);
    return copyWith(favoriteWallpaperIds: newFavorites);
  }

  UserPreferences removeFavorite(String wallpaperId) {
    if (!isFavorite(wallpaperId)) return this;
    
    final newFavorites = List<String>.from(favoriteWallpaperIds)..remove(wallpaperId);
    return copyWith(favoriteWallpaperIds: newFavorites);
  }

  UserPreferences toggleFavorite(String wallpaperId) {
    return isFavorite(wallpaperId) 
        ? removeFavorite(wallpaperId) 
        : addFavorite(wallpaperId);
  }
}