import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/niche.dart';
import '../../providers/wallpaper_provider.dart';

class NicheSelectionScreen extends StatefulWidget {
  const NicheSelectionScreen({super.key});

  @override
  State<NicheSelectionScreen> createState() => _NicheSelectionScreenState();
}

class _NicheSelectionScreenState extends State<NicheSelectionScreen> {
  final Set<String> _selectedNiches = {};

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
          'Choose Your Style',
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
                    value: 0.5,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '1 of 2',
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
              'Select the categories you love. We\'ll show you beautiful wallpapers from these niches.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Niches grid
          Expanded(
            child: Consumer<WallpaperProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.niches.length,
                  itemBuilder: (context, index) {
                    final niche = provider.niches[index];
                    final isSelected = _selectedNiches.contains(niche.id);

                    return _buildNicheCard(niche, isSelected);
                  },
                );
              },
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${_selectedNiches.length} categories selected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedNiches.isNotEmpty ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicheCard(Niche niche, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleNiche(niche.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getNicheIcon(niche.iconName),
                size: 32,
                color: isSelected ? Colors.white : const Color(0xFF667eea),
              ),
              const SizedBox(height: 12),
              Text(
                niche.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                niche.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNicheIcon(String iconName) {
    final iconMap = {
      'nature': Icons.landscape,
      'architecture': Icons.business,
      'texture': Icons.texture,
      'wallpaper': Icons.wallpaper,
      'experimental': Icons.science,
      'animals': Icons.pets,
      'travel': Icons.flight,
      'film': Icons.movie,
      'people': Icons.people,
      'spirituality': Icons.self_improvement,
      'arts': Icons.palette,
      'history': Icons.museum,
      'street': Icons.location_city,
      'fashion': Icons.checkroom,
      'events': Icons.event,
      'business': Icons.work,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }

  void _toggleNiche(String nicheId) {
    setState(() {
      if (_selectedNiches.contains(nicheId)) {
        _selectedNiches.remove(nicheId);
      } else {
        _selectedNiches.add(nicheId);
      }
    });
  }

  void _onContinue() {
    Navigator.of(context).pushNamed(
      '/interval-selection',
      arguments: _selectedNiches.toList(),
    );
  }
}