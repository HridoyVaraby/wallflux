// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WallpaperAdapter extends TypeAdapter<Wallpaper> {
  @override
  final int typeId = 0;

  @override
  Wallpaper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallpaper(
      id: fields[0] as String,
      description: fields[1] as String,
      altDescription: fields[2] as String?,
      urls: fields[3] as WallpaperUrls,
      user: fields[4] as WallpaperUser,
      createdAt: fields[5] as String,
      tags: (fields[6] as List).cast<String>(),
      isFavorite: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Wallpaper obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.altDescription)
      ..writeByte(3)
      ..write(obj.urls)
      ..writeByte(4)
      ..write(obj.user)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WallpaperUrlsAdapter extends TypeAdapter<WallpaperUrls> {
  @override
  final int typeId = 1;

  @override
  WallpaperUrls read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WallpaperUrls(
      raw: fields[0] as String,
      full: fields[1] as String,
      regular: fields[2] as String,
      small: fields[3] as String,
      thumb: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WallpaperUrls obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.raw)
      ..writeByte(1)
      ..write(obj.full)
      ..writeByte(2)
      ..write(obj.regular)
      ..writeByte(3)
      ..write(obj.small)
      ..writeByte(4)
      ..write(obj.thumb);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperUrlsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WallpaperUserAdapter extends TypeAdapter<WallpaperUser> {
  @override
  final int typeId = 2;

  @override
  WallpaperUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WallpaperUser(
      id: fields[0] as String,
      username: fields[1] as String,
      name: fields[2] as String,
      profileImage: fields[3] as WallpaperUserProfileImage?,
    );
  }

  @override
  void write(BinaryWriter writer, WallpaperUser obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WallpaperUserProfileImageAdapter
    extends TypeAdapter<WallpaperUserProfileImage> {
  @override
  final int typeId = 3;

  @override
  WallpaperUserProfileImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WallpaperUserProfileImage(
      small: fields[0] as String,
      medium: fields[1] as String,
      large: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WallpaperUserProfileImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.small)
      ..writeByte(1)
      ..write(obj.medium)
      ..writeByte(2)
      ..write(obj.large);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperUserProfileImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallpaper _$WallpaperFromJson(Map<String, dynamic> json) => Wallpaper(
      id: json['id'] as String,
      description: json['description'] as String,
      altDescription: json['alt_description'] as String?,
      urls: WallpaperUrls.fromJson(json['urls'] as Map<String, dynamic>),
      user: WallpaperUser.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$WallpaperToJson(Wallpaper instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'alt_description': instance.altDescription,
      'urls': instance.urls,
      'user': instance.user,
      'created_at': instance.createdAt,
      'tags': instance.tags,
      'isFavorite': instance.isFavorite,
    };

WallpaperUrls _$WallpaperUrlsFromJson(Map<String, dynamic> json) =>
    WallpaperUrls(
      raw: json['raw'] as String,
      full: json['full'] as String,
      regular: json['regular'] as String,
      small: json['small'] as String,
      thumb: json['thumb'] as String,
    );

Map<String, dynamic> _$WallpaperUrlsToJson(WallpaperUrls instance) =>
    <String, dynamic>{
      'raw': instance.raw,
      'full': instance.full,
      'regular': instance.regular,
      'small': instance.small,
      'thumb': instance.thumb,
    };

WallpaperUser _$WallpaperUserFromJson(Map<String, dynamic> json) =>
    WallpaperUser(
      id: json['id'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] == null
          ? null
          : WallpaperUserProfileImage.fromJson(
              json['profile_image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WallpaperUserToJson(WallpaperUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'profile_image': instance.profileImage,
    };

WallpaperUserProfileImage _$WallpaperUserProfileImageFromJson(
        Map<String, dynamic> json) =>
    WallpaperUserProfileImage(
      small: json['small'] as String,
      medium: json['medium'] as String,
      large: json['large'] as String,
    );

Map<String, dynamic> _$WallpaperUserProfileImageToJson(
        WallpaperUserProfileImage instance) =>
    <String, dynamic>{
      'small': instance.small,
      'medium': instance.medium,
      'large': instance.large,
    };
