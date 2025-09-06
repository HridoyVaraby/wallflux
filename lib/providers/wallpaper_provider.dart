import 'package:flutter/foundation.dart';
import '../models/wallpaper.dart';
import '../models/user_preferences.dart';
import '../models/niche.dart';
import '../services/unsplash_service.dart';
import '../services/local_storage_service.dart';
import '../services/wallpaper_service.dart';

class WallpaperProvider extends ChangeNotifier {
  final UnsplashService _unsplashService;
  final LocalStorageService _localStorage;
  final WallpaperService _wallpaperService;

  WallpaperProvider({
    UnsplashService? unsplashService,
    LocalStorageService? localStorage,
    WallpaperService? wallpaperService,
  })  : _unsplashService = unsplashService ?? UnsplashService(),
        _localStorage = localStorage ?? LocalStorageService.instance,
        _wallpaperService = wallpaperService ?? WallpaperService.instance;

  // State variables
  List<Wallpaper> _wallpapers = [];
  List<Niche> _niches = [];
  UserPreferences _userPreferences = UserPreferences();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  Wallpaper? _currentWallpaper;

  // Getters
  List<Wallpaper> get wallpapers => _wallpapers;
  List<Niche> get niches => _niches;
  UserPreferences get userPreferences => _userPreferences;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  Wallpaper? get currentWallpaper => _currentWallpaper;
  
  List<Niche> get selectedNiches => _niches
      .where((niche) => _userPreferences.selectedNiches.contains(niche.id))
      .toList();
  
  List<Wallpaper> get favoriteWallpapers => _wallpapers
      .where((wallpaper) => _userPreferences.isFavorite(wallpaper.id))
      .toList();

  bool get shouldShowOnboarding => _userPreferences.shouldShowOnboarding;

  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);

    try {
      await _localStorage.initialize();
      await _loadUserPreferences();
      await _loadNiches();
      await _loadCurrentWallpaper();
      
      if (!shouldShowOnboarding) {
        await loadWallpapers(refresh: true);
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user preferences
  Future<void> _loadUserPreferences() async {
    _userPreferences = await _localStorage.getUserPreferences();
    notifyListeners();
  }

  // Load niches
  Future<void> _loadNiches() async {
    _niches = await _localStorage.getAllNiches();
    notifyListeners();
  }

  // Load current wallpaper
  Future<void> _loadCurrentWallpaper() async {
    _currentWallpaper = await _localStorage.getCurrentWallpaper();
    notifyListeners();
  }

  // Load wallpapers based on user preferences
  Future<void> loadWallpapers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      _wallpapers.clear();
      _setLoading(true);
    } else {
      if (!_hasMorePages || _isLoadingMore) return;
      _setLoadingMore(true);
    }

    _setError(null);

    try {
      List<Wallpaper> newWallpapers;
      
      if (_userPreferences.selectedNiches.isNotEmpty) {
        // Load wallpapers from selected niches
        newWallpapers = await _loadWallpapersFromNiches();
      } else {
        // Load featured wallpapers
        newWallpapers = await _unsplashService.getFeaturedWallpapers(
          page: _currentPage,
          perPage: 30,
        );
      }

      if (newWallpapers.isNotEmpty) {
        _wallpapers.addAll(newWallpapers);
        _currentPage++;
        
        // Cache wallpapers for offline use
        await _localStorage.cacheBulkWallpapers(newWallpapers);
        await _localStorage.saveWallpapers(newWallpapers);
      } else {
        _hasMorePages = false;
      }
    } catch (e) {
      _setError('Failed to load wallpapers: $e');
      
      // Try to load cached wallpapers if network fails
      if (refresh && _wallpapers.isEmpty) {
        await _loadCachedWallpapers();
      }
    } finally {
      _setLoading(false);
      _setLoadingMore(false);
    }
  }

  // Load wallpapers from selected niches
  Future<List<Wallpaper>> _loadWallpapersFromNiches() async {
    final selectedNicheIds = _userPreferences.selectedNiches;
    final List<Wallpaper> allWallpapers = [];

    for (final nicheId in selectedNicheIds) {
      try {
        final wallpapers = await _unsplashService.getWallpapersByCategory(
          category: nicheId,
          page: _currentPage,
          perPage: 10, // Smaller batch per niche
        );
        allWallpapers.addAll(wallpapers);
      } catch (e) {
        print('Error loading wallpapers for niche $nicheId: $e');
      }
    }

    // Shuffle for variety
    allWallpapers.shuffle();
    return allWallpapers.take(30).toList();
  }

  // Load cached wallpapers for offline use
  Future<void> _loadCachedWallpapers() async {
    try {
      final cachedWallpapers = await _localStorage.getCachedWallpapers();
      if (cachedWallpapers.isNotEmpty) {
        _wallpapers = cachedWallpapers;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cached wallpapers: $e');
    }
  }

  // Set wallpaper
  Future<bool> setWallpaper(Wallpaper wallpaper) async {
    try {
      final success = await _wallpaperService.setWallpaper(wallpaper);
      if (success) {
        _currentWallpaper = wallpaper;
        await _localStorage.setCurrentWallpaper(wallpaper.id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to set wallpaper: $e');
      return false;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String wallpaperId) async {
    try {
      await _localStorage.toggleWallpaperFavorite(wallpaperId);
      _userPreferences = await _localStorage.getUserPreferences();
      
      // Update wallpaper in the list
      final index = _wallpapers.indexWhere((w) => w.id == wallpaperId);
      if (index != -1) {
        _wallpapers[index] = _wallpapers[index].copyWith(
          isFavorite: _userPreferences.isFavorite(wallpaperId),
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      await _localStorage.saveUserPreferences(preferences);
      _userPreferences = preferences;
      notifyListeners();
      
      // Reload wallpapers if niches changed
      if (preferences.selectedNiches != _userPreferences.selectedNiches) {
        await loadWallpapers(refresh: true);
      }
    } catch (e) {
      _setError('Failed to update preferences: $e');
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding({
    required List<String> selectedNicheIds,
    required int updateIntervalMinutes,
    String? customUpdateTime,
    bool useCustomTime = false,
  }) async {
    try {
      final updatedPreferences = _userPreferences.copyWith(
        selectedNiches: selectedNicheIds,
        updateIntervalMinutes: updateIntervalMinutes,
        customUpdateTime: customUpdateTime,
        useCustomTime: useCustomTime,
        isFirstLaunch: false,
      );
      
      await updateUserPreferences(updatedPreferences);
      
      // Load wallpapers after onboarding
      await loadWallpapers(refresh: true);
    } catch (e) {
      _setError('Failed to complete onboarding: $e');
    }
  }

  // Search wallpapers
  Future<void> searchWallpapers(String query) async {
    _setLoading(true);
    _setError(null);
    _wallpapers.clear();
    _currentPage = 1;
    _hasMorePages = true;

    try {
      final response = await _unsplashService.searchWallpapers(
        query: query,
        page: _currentPage,
        perPage: 30,
      );
      
      _wallpapers = response.results;
      _currentPage++;
      _hasMorePages = _currentPage <= response.totalPages;
      
      // Cache search results
      await _localStorage.cacheBulkWallpapers(_wallpapers);
      await _localStorage.saveWallpapers(_wallpapers);
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get random wallpaper for auto-update
  Future<Wallpaper?> getRandomWallpaperForUpdate() async {
    try {
      if (_userPreferences.rotateOnlyFavorites) {
        final favorites = await _localStorage.getFavoriteWallpapers();
        if (favorites.isNotEmpty) {
          favorites.shuffle();
          return favorites.first;
        }
      }
      
      // Get random wallpaper from selected niches
      if (_userPreferences.selectedNiches.isNotEmpty) {
        final randomWallpapers = await _unsplashService.getRandomWallpapers(
          categories: _userPreferences.selectedNiches,
          count: 1,
        );
        if (randomWallpapers.isNotEmpty) {
          return randomWallpapers.first;
        }
      }
      
      // Fallback to cached wallpapers
      final cached = await _localStorage.getCachedWallpapers(limit: 10);
      if (cached.isNotEmpty) {
        cached.shuffle();
        return cached.first;
      }
      
      return null;
    } catch (e) {
      print('Error getting random wallpaper: $e');
      return null;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clean up
  @override
  void dispose() {
    _unsplashService.dispose();
    super.dispose();
  }
}