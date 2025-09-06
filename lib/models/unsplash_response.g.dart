// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsplash_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnsplashSearchResponse _$UnsplashSearchResponseFromJson(
        Map<String, dynamic> json) =>
    UnsplashSearchResponse(
      total: (json['total'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UnsplashSearchResponseToJson(
        UnsplashSearchResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'total_pages': instance.totalPages,
      'results': instance.results,
    };

UnsplashCollection _$UnsplashCollectionFromJson(Map<String, dynamic> json) =>
    UnsplashCollection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalPhotos: (json['total_photos'] as num).toInt(),
      coverPhoto: json['cover_photo'] == null
          ? null
          : Wallpaper.fromJson(json['cover_photo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnsplashCollectionToJson(UnsplashCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'total_photos': instance.totalPhotos,
      'cover_photo': instance.coverPhoto,
    };
