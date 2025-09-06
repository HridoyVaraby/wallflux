import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallpaper.dart';
import '../models/user_preferences.dart';
import '../models/niche.dart';

class LocalStorageService {
  static const String _userPreferencesBox = 'user_preferences';
  static const String _wallpapersBox = 'wallpapers';
  static const String _nichesBox = 'niches';
  static const String _cachedWallpapersBox = 'cached_wallpapers';

  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  
  LocalStorageService._();

  bool _isInitialized = false;

  /// Initialize Hive and open all required boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WallpaperAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WallpaperUrlsAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WallpaperUserAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(WallpaperUserProfileImageAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NicheAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }

    // Open boxes
    await Future.wait([
      Hive.openBox<UserPreferences>(_userPreferencesBox),
      Hive.openBox<Wallpaper>(_wallpapersBox),
      Hive.openBox<Niche>(_nichesBox),
      Hive.openBox<Wallpaper>(_cachedWallpapersBox),
    ]);

    _isInitialized = true;
  }

  /// Get user preferences box
  Box<UserPreferences> get _userPreferencesBoxInstance {
    return Hive.box<UserPreferences>(_userPreferencesBox);
  }

  /// Get wallpapers box
  Box<Wallpaper> get _wallpapersBoxInstance {
    return Hive.box<Wallpaper>(_wallpapersBox);
  }

  /// Get niches box
  Box<Niche> get _nichesBoxInstance {
    return Hive.box<Niche>(_nichesBox);
  }

  /// Get cached wallpapers box
  Box<Wallpaper> get _cachedWallpapersBoxInstance {
    return Hive.box<Wallpaper>(_cachedWallpapersBox);
  }

  // User Preferences Methods
  Future<UserPreferences> getUserPreferences() async {
    final box = _userPreferencesBoxInstance;
    return box.get('preferences') ?? UserPreferences();
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final box = _userPreferencesBoxInstance;
    await box.put('preferences', preferences);
  }

  Future<void> updateUserPreferences(UserPreferences Function(UserPreferences) updater) async {
    final current = await getUserPreferences();
    final updated = updater(current);
    await saveUserPreferences(updated);
  }

  // Niches Methods
  Future<List<Niche>> getAllNiches() async {
    final box = _nichesBoxInstance;
    if (box.isEmpty) {
      // Initialize with predefined niches
      await initializeNiches();
    }
    return box.values.toList();
  }

  Future<void> initializeNiches() async {
    final box = _nichesBoxInstance;
    await box.clear();
    
    for (final niche in Niche.predefinedNiches) {
      await box.put(niche.id, niche);
    }
  }

  Future<void> updateNiche(Niche niche) async {
    final box = _nichesBoxInstance;
    await box.put(niche.id, niche);
  }

  Future<List<Niche>> getSelectedNiches() async {
    final preferences = await getUserPreferences();
    final allNiches = await getAllNiches();
    
    return allNiches
        .where((niche) => preferences.selectedNiches.contains(niche.id))
        .toList();
  }

  // Wallpapers Methods
  Future<void> saveWallpaper(Wallpaper wallpaper) async {
    final box = _wallpapersBoxInstance;
    await box.put(wallpaper.id, wallpaper);
  }

  Future<void> saveWallpapers(List<Wallpaper> wallpapers) async {
    final box = _wallpapersBoxInstance;
    final wallpaperMap = {for (var w in wallpapers) w.id: w};
    await box.putAll(wallpaperMap);
  }

  Future<Wallpaper?> getWallpaper(String id) async {
    final box = _wallpapersBoxInstance;
    return box.get(id);
  }

  Future<List<Wallpaper>> getAllWallpapers() async {
    final box = _wallpapersBoxInstance;
    return box.values.toList();
  }

  Future<List<Wallpaper>> getFavoriteWallpapers() async {
    final preferences = await getUserPreferences();
    final box = _wallpapersBoxInstance;
    
    return preferences.favoriteWallpaperIds
        .map((id) => box.get(id))
        .where((wallpaper) => wallpaper != null)
        .cast<Wallpaper>()
        .toList();
  }

  Future<void> toggleWallpaperFavorite(String wallpaperId) async {
    await updateUserPreferences((prefs) => prefs.toggleFavorite(wallpaperId));
  }

  Future<bool> isWallpaperFavorite(String wallpaperId) async {
    final preferences = await getUserPreferences();
    return preferences.isFavorite(wallpaperId);
  }

  // Cached Wallpapers Methods (for offline support)
  Future<void> cacheBulkWallpapers(List<Wallpaper> wallpapers) async {
    final box = _cachedWallpapersBoxInstance;
    final wallpaperMap = {for (var w in wallpapers) w.id: w};
    await box.putAll(wallpaperMap);
    
    // Keep only latest 100 cached wallpapers to save space
    if (box.length > 100) {
      final keys = box.keys.toList();
      final keysToDelete = keys.take(keys.length - 100);
      await box.deleteAll(keysToDelete);
    }
  }

  Future<List<Wallpaper>> getCachedWallpapers({int limit = 30}) async {
    final box = _cachedWallpapersBoxInstance;
    final wallpapers = box.values.toList();
    
    if (wallpapers.length <= limit) {
      return wallpapers;
    }
    
    // Return latest cached wallpapers
    wallpapers.shuffle(); // Random selection for variety
    return wallpapers.take(limit).toList();
  }

  Future<bool> hasCachedWallpapers() async {
    final box = _cachedWallpapersBoxInstance;
    return box.isNotEmpty;
  }

  // Settings and Current Wallpaper
  Future<void> setCurrentWallpaper(String wallpaperId) async {
    await updateUserPreferences((prefs) => prefs.copyWith(
      currentWallpaperId: wallpaperId,
      lastUpdateTime: DateTime.now(),
    ));
  }

  Future<Wallpaper?> getCurrentWallpaper() async {
    final preferences = await getUserPreferences();
    if (preferences.currentWallpaperId == null) return null;
    
    return await getWallpaper(preferences.currentWallpaperId!);
  }

  // Cleanup and maintenance
  Future<void> clearCache() async {
    final box = _cachedWallpapersBoxInstance;
    await box.clear();
  }

  Future<void> clearAllData() async {
    await Future.wait([
      _userPreferencesBoxInstance.clear(),
      _wallpapersBoxInstance.clear(),
      _nichesBoxInstance.clear(),
      _cachedWallpapersBoxInstance.clear(),
    ]);
  }

  Future<int> getCacheSize() async {
    return _cachedWallpapersBoxInstance.length + _wallpapersBoxInstance.length;
  }

  /// Close all boxes and clean up
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await Future.wait([
      Hive.box<UserPreferences>(_userPreferencesBox).close(),
      Hive.box<Wallpaper>(_wallpapersBox).close(),
      Hive.box<Niche>(_nichesBox).close(),
      Hive.box<Wallpaper>(_cachedWallpapersBox).close(),
    ]);
    
    _isInitialized = false;
  }
}