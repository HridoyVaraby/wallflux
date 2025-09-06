import 'package:json_annotation/json_annotation.dart';
import 'wallpaper.dart';

part 'unsplash_response.g.dart';

@JsonSerializable()
class UnsplashSearchResponse {
  final int total;
  
  @JsonKey(name: 'total_pages')
  final int totalPages;
  
  final List<Wallpaper> results;

  UnsplashSearchResponse({
    required this.total,
    required this.totalPages,
    required this.results,
  });

  factory UnsplashSearchResponse.fromJson(Map<String, dynamic> json) => 
      _$UnsplashSearchResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$UnsplashSearchResponseToJson(this);
}

@JsonSerializable()
class UnsplashCollection {
  final String id;
  final String title;
  final String? description;
  
  @JsonKey(name: 'total_photos')
  final int totalPhotos;
  
  @JsonKey(name: 'cover_photo')
  final Wallpaper? coverPhoto;

  UnsplashCollection({
    required this.id,
    required this.title,
    this.description,
    required this.totalPhotos,
    this.coverPhoto,
  });

  factory UnsplashCollection.fromJson(Map<String, dynamic> json) => 
      _$UnsplashCollectionFromJson(json);
  
  Map<String, dynamic> toJson() => _$UnsplashCollectionToJson(this);
}