import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/niche.dart';
import '../../providers/wallpaper_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current wallpaper section
                if (provider.currentWallpaper != null)
                  _buildCurrentWallpaperSection(provider),

                const SizedBox(height: 16),

                // Auto-update settings
                _buildAutoUpdateSection(provider),

                const SizedBox(height: 16),

                // Categories section
                _buildCategoriesSection(provider),

                const SizedBox(height: 16),

                // Favorites section
                _buildFavoritesSection(provider),

                const SizedBox(height: 16),

                // Cache and storage
                _buildCacheSection(provider),

                const SizedBox(height: 16),

                // App info
                _buildAppInfoSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentWallpaperSection(WallpaperProvider provider) {
    final wallpaper = provider.currentWallpaper!;
    
    return _buildSectionCard(
      title: 'Current Wallpaper',
      children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.network(
                wallpaper.urls.thumb,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              ),
            ),
          ),
          title: Text(
            wallpaper.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('by ${wallpaper.user.name}'),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _updateWallpaperNow(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoUpdateSection(WallpaperProvider provider) {
    final prefs = provider.userPreferences;
    
    return _buildSectionCard(
      title: 'Auto Update',
      children: [
        SwitchListTile(
          title: const Text('Enable Auto Update'),
          subtitle: const Text('Automatically change wallpaper'),
          value: prefs.isAutoUpdateEnabled,
          onChanged: (value) => _updateAutoUpdate(provider, value),
        ),
        
        if (prefs.isAutoUpdateEnabled) ...[
          const Divider(),
          
          // Update frequency
          ListTile(
            title: const Text('Update Frequency'),
            subtitle: Text(prefs.useCustomTime && prefs.customUpdateTime != null
                ? 'Daily at ${prefs.customUpdateTime}'
                : prefs.updateIntervalDisplay),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showIntervalDialog(provider),
          ),
          
          const Divider(),
          
          // Rotate only favorites
          SwitchListTile(
            title: const Text('Favorites Only'),
            subtitle: const Text('Only rotate through favorite wallpapers'),
            value: prefs.rotateOnlyFavorites,
            onChanged: (value) => _updateRotateOnlyFavorites(provider, value),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriesSection(WallpaperProvider provider) {
    final selectedNiches = provider.selectedNiches;
    
    return _buildSectionCard(
      title: 'Categories',
      children: [
        ListTile(
          title: const Text('Selected Categories'),
          subtitle: Text('${selectedNiches.length} categories selected'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCategoriesDialog(provider),
        ),
        
        // Show selected categories
        if (selectedNiches.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedNiches.map((niche) => Chip(
                label: Text(
                  niche.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                side: BorderSide(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoritesSection(WallpaperProvider provider) {
    final favoriteCount = provider.favoriteWallpapers.length;
    
    return _buildSectionCard(
      title: 'Favorites',
      children: [
        ListTile(
          title: const Text('Favorite Wallpapers'),
          subtitle: Text('$favoriteCount wallpapers saved'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFavorites(provider),
        ),
        
        if (favoriteCount > 0)
          ListTile(
            title: const Text('Set Random Favorite'),
            subtitle: const Text('Set a random wallpaper from favorites'),
            trailing: const Icon(Icons.shuffle),
            onTap: () => _setRandomFavorite(provider),
          ),
      ],
    );
  }

  Widget _buildCacheSection(WallpaperProvider provider) {
    return _buildSectionCard(
      title: 'Storage & Cache',
      children: [
        ListTile(
          title: const Text('Clear Cache'),
          subtitle: const Text('Free up storage space'),
          trailing: const Icon(Icons.delete_outline),
          onTap: () => _clearCache(provider),
        ),
        
        ListTile(
          title: const Text('Download Quality'),
          subtitle: const Text('Image quality for downloads'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showQualityDialog(),
        ),
      ],
    );
  }

  Widget _buildAppInfoSection() {
    return _buildSectionCard(
      title: 'About',
      children: [
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPrivacyPolicy(),
        ),
        
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showTermsOfService(),
        ),
        
        ListTile(
          title: const Text('Credits'),
          subtitle: const Text('Photos provided by Unsplash'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCredits(),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // Action methods
  void _updateAutoUpdate(WallpaperProvider provider, bool enabled) {
    final updatedPrefs = provider.userPreferences.copyWith(
      isAutoUpdateEnabled: enabled,
    );
    provider.updateUserPreferences(updatedPrefs);
  }

  void _updateRotateOnlyFavorites(WallpaperProvider provider, bool enabled) {
    final updatedPrefs = provider.userPreferences.copyWith(
      rotateOnlyFavorites: enabled,
    );
    provider.updateUserPreferences(updatedPrefs);
  }

  void _showIntervalDialog(WallpaperProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _IntervalSelectionDialog(
        currentPrefs: provider.userPreferences,
        onPreferencesChanged: (prefs) => provider.updateUserPreferences(prefs),
      ),
    );
  }

  void _showCategoriesDialog(WallpaperProvider provider) {
    showDialog(
      context: context,
      builder: (context) => _CategoriesSelectionDialog(
        allNiches: provider.niches,
        selectedNiches: provider.userPreferences.selectedNiches,
        onSelectionChanged: (selectedIds) {
          final updatedPrefs = provider.userPreferences.copyWith(
            selectedNiches: selectedIds,
          );
          provider.updateUserPreferences(updatedPrefs);
        },
      ),
    );
  }

  void _updateWallpaperNow(WallpaperProvider provider) async {
    final wallpaper = await provider.getRandomWallpaperForUpdate();
    if (wallpaper != null) {
      await provider.setWallpaper(wallpaper);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper updated!')),
        );
      }
    }
  }

  void _showFavorites(WallpaperProvider provider) {
    // TODO: Navigate to favorites screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorites screen coming soon!')),
    );
  }

  void _setRandomFavorite(WallpaperProvider provider) async {
    final favorites = provider.favoriteWallpapers;
    if (favorites.isNotEmpty) {
      favorites.shuffle();
      await provider.setWallpaper(favorites.first);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Random favorite wallpaper set!')),
        );
      }
    }
  }

  void _clearCache(WallpaperProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached wallpapers. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement cache clearing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showQualityDialog() {
    // TODO: Implement quality selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quality settings coming soon!')),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Show privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showTermsOfService() {
    // TODO: Show terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _showCredits() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credits'),
        content: const Text(
          'Beautiful photos provided by Unsplash and their amazing community of photographers.\n\nVisit unsplash.com to discover more incredible photography.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Dialog widgets
class _IntervalSelectionDialog extends StatefulWidget {
  final UserPreferences currentPrefs;
  final Function(UserPreferences) onPreferencesChanged;

  const _IntervalSelectionDialog({
    required this.currentPrefs,
    required this.onPreferencesChanged,
  });

  @override
  State<_IntervalSelectionDialog> createState() => _IntervalSelectionDialogState();
}

class _IntervalSelectionDialogState extends State<_IntervalSelectionDialog> {
  late int selectedInterval;
  late bool useCustomTime;
  TimeOfDay? customTime;

  @override
  void initState() {
    super.initState();
    selectedInterval = widget.currentPrefs.updateIntervalMinutes;
    useCustomTime = widget.currentPrefs.useCustomTime;
    if (widget.currentPrefs.customUpdateTime != null) {
      final parts = widget.currentPrefs.customUpdateTime!.split(':');
      customTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Frequency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...UserPreferences.intervalPresets.entries.map(
            (entry) => RadioListTile<int>(
              title: Text(entry.key),
              value: entry.value,
              groupValue: useCustomTime ? -1 : selectedInterval,
              onChanged: (value) {
                setState(() {
                  selectedInterval = value!;
                  useCustomTime = false;
                });
              },
            ),
          ),
          RadioListTile<bool>(
            title: Text(customTime != null 
                ? 'Custom time (${customTime!.format(context)})' 
                : 'Custom time'),
            value: true,
            groupValue: useCustomTime,
            onChanged: (value) async {
              final time = await showTimePicker(
                context: context,
                initialTime: customTime ?? const TimeOfDay(hour: 9, minute: 0),
              );
              if (time != null) {
                setState(() {
                  customTime = time;
                  useCustomTime = true;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String? customTimeString;
            if (useCustomTime && customTime != null) {
              customTimeString = '${customTime!.hour.toString().padLeft(2, '0')}:${customTime!.minute.toString().padLeft(2, '0')}';
            }

            final updatedPrefs = widget.currentPrefs.copyWith(
              updateIntervalMinutes: useCustomTime ? 1440 : selectedInterval,
              useCustomTime: useCustomTime,
              customUpdateTime: customTimeString,
            );
            
            widget.onPreferencesChanged(updatedPrefs);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CategoriesSelectionDialog extends StatefulWidget {
  final List<Niche> allNiches;
  final List<String> selectedNiches;
  final Function(List<String>) onSelectionChanged;

  const _CategoriesSelectionDialog({
    required this.allNiches,
    required this.selectedNiches,
    required this.onSelectionChanged,
  });

  @override
  State<_CategoriesSelectionDialog> createState() => _CategoriesSelectionDialogState();
}

class _CategoriesSelectionDialogState extends State<_CategoriesSelectionDialog> {
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = Set.from(widget.selectedNiches);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Categories'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: widget.allNiches.map((niche) {
            return CheckboxListTile(
              title: Text(niche.name),
              subtitle: Text(niche.description),
              value: selected.contains(niche.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selected.add(niche.id);
                  } else {
                    selected.remove(niche.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSelectionChanged(selected.toList());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}