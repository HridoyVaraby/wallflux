import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/wallpaper.dart';
import '../../providers/wallpaper_provider.dart';
import '../../services/wallpaper_service.dart';

class WallpaperPreviewScreen extends StatefulWidget {
  final Wallpaper wallpaper;

  const WallpaperPreviewScreen({
    super.key,
    required this.wallpaper,
  });

  @override
  State<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends State<WallpaperPreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _isUIVisible = true;
  bool _isSettingWallpaper = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Auto-hide UI after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideUI();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
    });
  }

  void _hideUI() {
    if (_isUIVisible) {
      setState(() {
        _isUIVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _isUIVisible
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                Consumer<WallpaperProvider>(
                  builder: (context, provider, child) {
                    final isFavorite = provider.userPreferences.isFavorite(widget.wallpaper.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => provider.toggleFavorite(widget.wallpaper.id),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareWallpaper,
                ),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light,
            )
          : null,
      body: GestureDetector(
        onTap: _toggleUI,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Wallpaper image
            Hero(
              tag: 'wallpaper_${widget.wallpaper.id}',
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.urls.regular,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom sheet with wallpaper info and actions
            if (_isUIVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Wallpaper info
                          _buildWallpaperInfo(),
                          
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Loading overlay when setting wallpaper
            if (_isSettingWallpaper)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Setting wallpaper...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.wallpaper.description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (widget.wallpaper.user.profileImage != null)
              CircleAvatar(
                radius: 12,
                backgroundImage: CachedNetworkImageProvider(
                  widget.wallpaper.user.profileImage!.small,
                ),
              ),
            if (widget.wallpaper.user.profileImage != null)
              const SizedBox(width: 8),
            Expanded(
              child: Text(
                'by ${widget.wallpaper.user.name}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        if (widget.wallpaper.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.wallpaper.tags.take(5).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Set Wallpaper button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isSettingWallpaper ? null : () => _setWallpaper(WallpaperLocation.bothScreens),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.wallpaper),
            label: const Text(
              'Set as Wallpaper',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Wallpaper location options
        Row(
          children: [
            Expanded(
              child: _buildLocationButton(
                'Home Screen',
                Icons.home,
                () => _setWallpaper(WallpaperLocation.homeScreen),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLocationButton(
                'Lock Screen',
                Icons.lock,
                () => _setWallpaper(WallpaperLocation.lockScreen),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isSettingWallpaper ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _setWallpaper(WallpaperLocation location) async {
    setState(() {
      _isSettingWallpaper = true;
    });

    try {
      final provider = Provider.of<WallpaperProvider>(context, listen: false);
      final success = await provider.setWallpaper(widget.wallpaper);

      if (mounted) {
        setState(() {
          _isSettingWallpaper = false;
        });

        if (success) {
          _showSnackBar(
            'Wallpaper set successfully!',
            Colors.green,
            Icons.check_circle,
          );
        } else {
          _showSnackBar(
            'Failed to set wallpaper. Please try again.',
            Colors.red,
            Icons.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSettingWallpaper = false;
        });
        
        _showSnackBar(
          'Error setting wallpaper: $e',
          Colors.red,
          Icons.error,
        );
      }
    }
  }

  void _shareWallpaper() {
    // TODO: Implement sharing functionality
    _showSnackBar(
      'Share feature coming soon!',
      Colors.blue,
      Icons.info,
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}