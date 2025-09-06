import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../services/local_storage_service.dart';
import '../services/unsplash_service.dart';
import '../services/wallpaper_service.dart';

class BackgroundSchedulerService {
  static const String _isolatePortName = 'wallflux_isolate_port';
  static const int _alarmId = 0;
  
  static BackgroundSchedulerService? _instance;
  static BackgroundSchedulerService get instance => _instance ??= BackgroundSchedulerService._();
  
  BackgroundSchedulerService._();

  bool _isInitialized = false;

  /// Initialize the background scheduler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await AndroidAlarmManager.initialize();
      _isInitialized = true;
      
      // Set up the isolate communication port
      _setupIsolatePort();
      
      print('Background scheduler initialized successfully');
    } catch (e) {
      print('Failed to initialize background scheduler: $e');
    }
  }

  /// Schedule wallpaper updates based on user preferences
  Future<void> scheduleWallpaperUpdates(UserPreferences preferences) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Cancel existing alarms
    await cancelScheduledUpdates();

    if (!preferences.isAutoUpdateEnabled) {
      print('Auto-update is disabled, not scheduling updates');
      return;
    }

    try {
      if (preferences.useCustomTime && preferences.customUpdateTime != null) {
        // Schedule daily at specific time
        await _scheduleDailyUpdate(preferences.customUpdateTime!);
      } else {
        // Schedule periodic updates
        await _schedulePeriodicUpdate(preferences.updateIntervalMinutes);
      }
      
      print('Wallpaper updates scheduled successfully');
    } catch (e) {
      print('Failed to schedule wallpaper updates: $e');
    }
  }

  /// Schedule periodic wallpaper updates
  Future<void> _schedulePeriodicUpdate(int intervalMinutes) async {
    final duration = Duration(minutes: intervalMinutes);
    
    await AndroidAlarmManager.periodic(
      duration,
      _alarmId,
      _backgroundWallpaperUpdate,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    print('Scheduled periodic updates every $intervalMinutes minutes');
  }

  /// Schedule daily wallpaper update at specific time
  Future<void> _scheduleDailyUpdate(String timeString) async {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      _alarmId,
      _backgroundWallpaperUpdate,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    // Schedule the next daily update
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      _alarmId + 1,
      _backgroundWallpaperUpdate,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      startAt: scheduledTime,
    );
    
    print('Scheduled daily update at $timeString');
  }

  /// Cancel all scheduled wallpaper updates
  Future<void> cancelScheduledUpdates() async {
    try {
      await AndroidAlarmManager.cancel(_alarmId);
      await AndroidAlarmManager.cancel(_alarmId + 1);
      print('Cancelled scheduled wallpaper updates');
    } catch (e) {
      print('Error cancelling scheduled updates: $e');
    }
  }

  /// Set up isolate port for communication
  void _setupIsolatePort() {
    final port = ReceivePort();
    IsolateNameServer.registerPortWithName(port.sendPort, _isolatePortName);
    
    port.listen((data) {
      if (data is String && data == 'wallpaper_updated') {
        print('Received wallpaper update confirmation from background');
      }
    });
  }

  /// Update wallpaper immediately (for testing or manual trigger)
  Future<void> updateWallpaperNow() async {
    try {
      await _backgroundWallpaperUpdate(_alarmId);
    } catch (e) {
      print('Error updating wallpaper now: $e');
    }
  }

  /// Check if background updates are scheduled
  Future<bool> areUpdatesScheduled() async {
    // This is a simplified check - in a real app you might want to store
    // scheduling state in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('wallpaper_updates_scheduled') ?? false;
  }

  /// Enable/disable background updates
  Future<void> setUpdatesEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallpaper_updates_scheduled', enabled);
  }
}

/// Background wallpaper update function that runs in isolate
@pragma('vm:entry-point')
Future<void> _backgroundWallpaperUpdate(int id) async {
  print('Background wallpaper update triggered with ID: $id');
  
  try {
    // Initialize services in the background isolate
    final localStorage = LocalStorageService.instance;
    await localStorage.initialize();
    
    // Get user preferences
    final userPreferences = await localStorage.getUserPreferences();
    
    // Check if auto-update is still enabled
    if (!userPreferences.isAutoUpdateEnabled) {
      print('Auto-update disabled, skipping update');
      return;
    }
    
    // Check if we should only rotate favorites
    if (userPreferences.rotateOnlyFavorites) {
      await _updateFromFavorites(localStorage);
    } else {
      await _updateFromSelectedNiches(localStorage, userPreferences);
    }
    
    // Send confirmation back to main isolate
    _sendUpdateConfirmation();
    
  } catch (e) {
    print('Error in background wallpaper update: $e');
  }
}

/// Update wallpaper from favorites
Future<void> _updateFromFavorites(LocalStorageService localStorage) async {
  try {
    final favorites = await localStorage.getFavoriteWallpapers();
    
    if (favorites.isEmpty) {
      print('No favorite wallpapers found, skipping update');
      return;
    }
    
    // Select random favorite
    favorites.shuffle();
    final selectedWallpaper = favorites.first;
    
    // Set wallpaper
    final wallpaperService = WallpaperService.instance;
    final success = await wallpaperService.setWallpaper(selectedWallpaper);
    
    if (success) {
      await localStorage.setCurrentWallpaper(selectedWallpaper.id);
      print('Background update: Set favorite wallpaper ${selectedWallpaper.id}');
    } else {
      print('Background update: Failed to set favorite wallpaper');
    }
    
  } catch (e) {
    print('Error updating from favorites: $e');
  }
}

/// Update wallpaper from selected niches
Future<void> _updateFromSelectedNiches(
  LocalStorageService localStorage,
  UserPreferences userPreferences,
) async {
  try {
    if (userPreferences.selectedNiches.isEmpty) {
      print('No niches selected, using cached wallpapers');
      await _updateFromCache(localStorage);
      return;
    }
    
    // Try to get a new wallpaper from Unsplash
    final unsplashService = UnsplashService();
    
    try {
      final randomWallpapers = await unsplashService.getRandomWallpapers(
        categories: userPreferences.selectedNiches,
        count: 1,
      );
      
      if (randomWallpapers.isNotEmpty) {
        final selectedWallpaper = randomWallpapers.first;
        
        // Set wallpaper
        final wallpaperService = WallpaperService.instance;
        final success = await wallpaperService.setWallpaper(selectedWallpaper);
        
        if (success) {
          await localStorage.saveWallpaper(selectedWallpaper);
          await localStorage.setCurrentWallpaper(selectedWallpaper.id);
          print('Background update: Set new wallpaper ${selectedWallpaper.id}');
        } else {
          print('Background update: Failed to set new wallpaper');
          // Fallback to cached wallpapers
          await _updateFromCache(localStorage);
        }
      } else {
        print('No new wallpapers found, using cached');
        await _updateFromCache(localStorage);
      }
    } catch (e) {
      print('Network error, using cached wallpapers: $e');
      await _updateFromCache(localStorage);
    }
    
    unsplashService.dispose();
    
  } catch (e) {
    print('Error updating from niches: $e');
  }
}

/// Update wallpaper from cache (offline fallback)
Future<void> _updateFromCache(LocalStorageService localStorage) async {
  try {
    final cachedWallpapers = await localStorage.getCachedWallpapers(limit: 20);
    
    if (cachedWallpapers.isEmpty) {
      print('No cached wallpapers found');
      return;
    }
    
    // Select random cached wallpaper
    cachedWallpapers.shuffle();
    final selectedWallpaper = cachedWallpapers.first;
    
    // Set wallpaper
    final wallpaperService = WallpaperService.instance;
    final success = await wallpaperService.setWallpaper(selectedWallpaper);
    
    if (success) {
      await localStorage.setCurrentWallpaper(selectedWallpaper.id);
      print('Background update: Set cached wallpaper ${selectedWallpaper.id}');
    } else {
      print('Background update: Failed to set cached wallpaper');
    }
    
  } catch (e) {
    print('Error updating from cache: $e');
  }
}

/// Send update confirmation to main isolate
void _sendUpdateConfirmation() {
  try {
    final sendPort = IsolateNameServer.lookupPortByName(
      BackgroundSchedulerService._isolatePortName,
    );
    sendPort?.send('wallpaper_updated');
  } catch (e) {
    print('Error sending update confirmation: $e');
  }
}