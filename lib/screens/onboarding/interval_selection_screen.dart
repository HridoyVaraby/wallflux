import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../providers/wallpaper_provider.dart';

class IntervalSelectionScreen extends StatefulWidget {
  final List<String> selectedNiches;

  const IntervalSelectionScreen({
    super.key,
    required this.selectedNiches,
  });

  @override
  State<IntervalSelectionScreen> createState() => _IntervalSelectionScreenState();
}

class _IntervalSelectionScreenState extends State<IntervalSelectionScreen> {
  int _selectedIntervalMinutes = 360; // Default: 6 hours
  bool _useCustomTime = false;
  TimeOfDay? _customTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Update Frequency',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '2 of 2',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'How often would you like your wallpaper to change automatically?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Interval options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preset Intervals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Preset intervals
                  ...UserPreferences.intervalPresets.entries.map(
                    (entry) => _buildIntervalOption(
                      title: entry.key,
                      minutes: entry.value,
                      isSelected: !_useCustomTime && _selectedIntervalMinutes == entry.value,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Custom time section
                  const Text(
                    'Custom Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildCustomTimeOption(),
                ],
              ),
            ),
          ),

          // Finish button
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _getSelectedIntervalDescription(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Consumer<WallpaperProvider>(
                    builder: (context, provider, child) {
                      return ElevatedButton(
                        onPressed: provider.isLoading ? null : _onFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Finish Setup',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalOption({
    required String title,
    required int minutes,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _selectInterval(minutes),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Text(
              _getIntervalDescription(minutes),
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTimeOption() {
    return GestureDetector(
      onTap: _selectCustomTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _useCustomTime ? const Color(0xFF667eea) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _useCustomTime ? const Color(0xFF667eea) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _useCustomTime ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _useCustomTime ? Colors.white : Colors.grey[400],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Daily Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _useCustomTime ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set a specific time each day',
                    style: TextStyle(
                      fontSize: 14,
                      color: _useCustomTime ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_customTime != null)
              Text(
                _customTime!.format(context),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _useCustomTime ? Colors.white : Colors.grey[600],
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.access_time,
              color: _useCustomTime ? Colors.white.withOpacity(0.8) : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getIntervalDescription(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '${hours}h';
    } else {
      return 'Daily';
    }
  }

  String _getSelectedIntervalDescription() {
    if (_useCustomTime && _customTime != null) {
      return 'Wallpaper will change daily at ${_customTime!.format(context)}';
    } else {
      final description = _getIntervalDescription(_selectedIntervalMinutes);
      return 'Wallpaper will change every $description';
    }
  }

  void _selectInterval(int minutes) {
    setState(() {
      _selectedIntervalMinutes = minutes;
      _useCustomTime = false;
    });
  }

  void _selectCustomTime() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: _customTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (timeOfDay != null) {
      setState(() {
        _customTime = timeOfDay;
        _useCustomTime = true;
      });
    }
  }

  void _onFinish() async {
    final provider = Provider.of<WallpaperProvider>(context, listen: false);
    
    String? customTimeString;
    if (_useCustomTime && _customTime != null) {
      customTimeString = '${_customTime!.hour.toString().padLeft(2, '0')}:${_customTime!.minute.toString().padLeft(2, '0')}';
    }

    await provider.completeOnboarding(
      selectedNicheIds: widget.selectedNiches,
      updateIntervalMinutes: _useCustomTime ? 1440 : _selectedIntervalMinutes, // Daily for custom time
      customUpdateTime: customTimeString,
      useCustomTime: _useCustomTime,
    );

    if (mounted) {
      // Navigate to main screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );
    }
  }
}