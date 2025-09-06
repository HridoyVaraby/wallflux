import 'package:hive/hive.dart';

part 'niche.g.dart';

@HiveType(typeId: 4)
class Niche extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String iconName;
  
  @HiveField(4)
  final bool isSelected;

  Niche({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.isSelected = false,
  });

  Niche copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    bool? isSelected,
  }) {
    return Niche(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  // Predefined niches for Unsplash categories
  static List<Niche> get predefinedNiches => [
    Niche(
      id: 'nature',
      name: 'Nature',
      description: 'Beautiful landscapes, forests, mountains, and wildlife',
      iconName: 'nature',
    ),
    Niche(
      id: 'architecture',
      name: 'Architecture',
      description: 'Buildings, structures, and urban photography',
      iconName: 'architecture',
    ),
    Niche(
      id: 'textures-patterns',
      name: 'Textures & Patterns',
      description: 'Abstract textures, patterns, and backgrounds',
      iconName: 'texture',
    ),
    Niche(
      id: 'wallpapers',
      name: 'Wallpapers',
      description: 'High-quality wallpapers for mobile and desktop',
      iconName: 'wallpaper',
    ),
    Niche(
      id: 'experimental',
      name: 'Experimental',
      description: 'Artistic and experimental photography',
      iconName: 'experimental',
    ),
    Niche(
      id: 'animals',
      name: 'Animals',
      description: 'Wildlife, pets, and animal photography',
      iconName: 'animals',
    ),
    Niche(
      id: 'travel',
      name: 'Travel',
      description: 'Places, destinations, and travel photography',
      iconName: 'travel',
    ),
    Niche(
      id: 'film',
      name: 'Film',
      description: 'Film photography and cinematic shots',
      iconName: 'film',
    ),
    Niche(
      id: 'people',
      name: 'People',
      description: 'Portraits, lifestyle, and people photography',
      iconName: 'people',
    ),
    Niche(
      id: 'spirituality',
      name: 'Spirituality',
      description: 'Peaceful, meditative, and spiritual imagery',
      iconName: 'spirituality',
    ),
    Niche(
      id: 'arts-culture',
      name: 'Arts & Culture',
      description: 'Art, culture, and creative photography',
      iconName: 'arts',
    ),
    Niche(
      id: 'history',
      name: 'History',
      description: 'Historical places, artifacts, and vintage photography',
      iconName: 'history',
    ),
    Niche(
      id: 'street-photography',
      name: 'Street Photography',
      description: 'Urban life, street art, and city photography',
      iconName: 'street',
    ),
    Niche(
      id: 'fashion-beauty',
      name: 'Fashion & Beauty',
      description: 'Fashion, beauty, and style photography',
      iconName: 'fashion',
    ),
    Niche(
      id: 'current-events',
      name: 'Current Events',
      description: 'News, events, and contemporary photography',
      iconName: 'events',
    ),
    Niche(
      id: 'business-work',
      name: 'Business & Work',
      description: 'Business, work, and professional photography',
      iconName: 'business',
    ),
  ];
}