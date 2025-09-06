import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionsService {
  static PermissionsService? _instance;
  static PermissionsService get instance => _instance ??= PermissionsService._();
  
  PermissionsService._();

  /// Check and request all required permissions
  Future<bool> requestAllPermissions(BuildContext context) async {
    final permissions = await _checkPermissions();
    
    if (permissions.allGranted) {
      return true;
    }

    // Show explanation dialog if needed
    if (permissions.shouldShowRationale) {
      final shouldContinue = await _showPermissionRationaleDialog(context);
      if (!shouldContinue) {
        return false;
      }
    }

    // Request permissions
    final results = await _requestPermissions();
    
    // Check if all permissions were granted
    if (results.allGranted) {
      return true;
    }

    // Show settings dialog if some permissions were permanently denied
    if (results.hasPermanentlyDenied) {
      await _showOpenSettingsDialog(context);
    }

    return false;
  }

  /// Check current permission status
  Future<PermissionStatus> checkPermissionStatus() async {
    final permissions = await _checkPermissions();
    
    if (permissions.allGranted) {
      return PermissionStatus.granted;
    } else if (permissions.hasPermanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    } else {
      return PermissionStatus.denied;
    }
  }

  /// Check if wallpaper permission is granted
  Future<bool> hasWallpaperPermission() async {
    // For Android, we check if we can set wallpapers
    // This is usually granted by default, but we can still check
    return true; // Most Android versions don't require explicit permission
  }

  /// Check if alarm permission is granted (Android 12+)
  Future<bool> hasExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }
    return false;
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission(BuildContext context) async {
    final status = await Permission.scheduleExactAlarm.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.scheduleExactAlarm.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      await _showOpenSettingsDialog(context, 
          title: 'Exact Alarm Permission Required',
          message: 'To automatically change wallpapers, we need permission to schedule exact alarms. Please enable this in settings.');
      return false;
    }

    return false;
  }

  /// Check individual permissions
  Future<_PermissionResults> _checkPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.scheduleExactAlarm,
    ].request();

    return _PermissionResults(statuses);
  }

  /// Request permissions
  Future<_PermissionResults> _requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.scheduleExactAlarm,
    ].request();

    return _PermissionResults(statuses);
  }

  /// Show permission rationale dialog
  Future<bool> _showPermissionRationaleDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'WallFlux needs the following permissions to work properly:\n\n'
            '• Internet access: To download beautiful wallpapers\n'
            '• Exact alarms: To automatically change wallpapers at your preferred times\n\n'
            'These permissions help us provide you with the best wallpaper experience.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show open settings dialog
  Future<void> _showOpenSettingsDialog(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Permissions Required'),
          content: Text(
            message ?? 
            'Some permissions were denied. To use all features of WallFlux, '
            'please enable the required permissions in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Check if the app has basic functionality permissions
  Future<bool> hasBasicPermissions() async {
    // Internet permission is usually granted automatically
    // We mainly need to check for wallpaper and alarm permissions
    return true;
  }

  /// Get permission status message for UI
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'All permissions granted';
      case PermissionStatus.denied:
        return 'Some permissions are required for full functionality';
      case PermissionStatus.permanentlyDenied:
        return 'Please enable permissions in settings';
      case PermissionStatus.restricted:
        return 'Permissions are restricted on this device';
      default:
        return 'Permission status unknown';
    }
  }
}

/// Helper class to manage permission results
class _PermissionResults {
  final Map<Permission, PermissionStatus> _statuses;

  _PermissionResults(this._statuses);

  bool get allGranted => _statuses.values.every((status) => status.isGranted);
  
  bool get hasPermanentlyDenied => _statuses.values.any((status) => status.isPermanentlyDenied);
  
  bool get shouldShowRationale => _statuses.values.any((status) => status.isDenied);
  
  List<Permission> get deniedPermissions => _statuses.entries
      .where((entry) => entry.value.isDenied)
      .map((entry) => entry.key)
      .toList();
  
  List<Permission> get permanentlyDeniedPermissions => _statuses.entries
      .where((entry) => entry.value.isPermanentlyDenied)
      .map((entry) => entry.key)
      .toList();
}