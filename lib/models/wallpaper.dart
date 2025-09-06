import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'wallpaper.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class Wallpaper extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String description;
  
  @HiveField(2)
  @JsonKey(name: 'alt_description')
  final String? altDescription;
  
  @HiveField(3)
  final WallpaperUrls urls;
  
  @HiveField(4)
  final WallpaperUser user;
  
  @HiveField(5)
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  @HiveField(6)
  final List<String> tags;
  
  @HiveField(7)
  final bool isFavorite;

  Wallpaper({
    required this.id,
    required this.description,
    this.altDescription,
    required this.urls,
    required this.user,
    required this.createdAt,
    this.tags = const [],
    this.isFavorite = false,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) => _$WallpaperFromJson(json);
  Map<String, dynamic> toJson() => _$WallpaperToJson(this);

  Wallpaper copyWith({
    String? id,
    String? description,
    String? altDescription,
    WallpaperUrls? urls,
    WallpaperUser? user,
    String? createdAt,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Wallpaper(
      id: id ?? this.id,
      description: description ?? this.description,
      altDescription: altDescription ?? this.altDescription,
      urls: urls ?? this.urls,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@JsonSerializable()
@HiveType(typeId: 1)
class WallpaperUrls extends HiveObject {
  @HiveField(0)
  final String raw;
  
  @HiveField(1)
  final String full;
  
  @HiveField(2)
  final String regular;
  
  @HiveField(3)
  final String small;
  
  @HiveField(4)
  final String thumb;

  WallpaperUrls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  factory WallpaperUrls.fromJson(Map<String, dynamic> json) => _$WallpaperUrlsFromJson(json);
  Map<String, dynamic> toJson() => _$WallpaperUrlsToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 2)
class WallpaperUser extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  @JsonKey(name: 'profile_image')
  final WallpaperUserProfileImage? profileImage;

  WallpaperUser({
    required this.id,
    required this.username,
    required this.name,
    this.profileImage,
  });

  factory WallpaperUser.fromJson(Map<String, dynamic> json) => _$WallpaperUserFromJson(json);
  Map<String, dynamic> toJson() => _$WallpaperUserToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 3)
class WallpaperUserProfileImage extends HiveObject {
  @HiveField(0)
  final String small;
  
  @HiveField(1)
  final String medium;
  
  @HiveField(2)
  final String large;

  WallpaperUserProfileImage({
    required this.small,
    required this.medium,
    required this.large,
  });

  factory WallpaperUserProfileImage.fromJson(Map<String, dynamic> json) => _$WallpaperUserProfileImageFromJson(json);
  Map<String, dynamic> toJson() => _$WallpaperUserProfileImageToJson(this);
}