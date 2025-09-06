// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 5;

  @override
  UserPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferences(
      selectedNiches: (fields[0] as List).cast<String>(),
      updateIntervalMinutes: fields[1] as int,
      isAutoUpdateEnabled: fields[2] as bool,
      isFirstLaunch: fields[3] as bool,
      customUpdateTime: fields[4] as String?,
      useCustomTime: fields[5] as bool,
      currentWallpaperId: fields[6] as String?,
      favoriteWallpaperIds: (fields[7] as List).cast<String>(),
      rotateOnlyFavorites: fields[8] as bool,
      lastUpdateTime: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.selectedNiches)
      ..writeByte(1)
      ..write(obj.updateIntervalMinutes)
      ..writeByte(2)
      ..write(obj.isAutoUpdateEnabled)
      ..writeByte(3)
      ..write(obj.isFirstLaunch)
      ..writeByte(4)
      ..write(obj.customUpdateTime)
      ..writeByte(5)
      ..write(obj.useCustomTime)
      ..writeByte(6)
      ..write(obj.currentWallpaperId)
      ..writeByte(7)
      ..write(obj.favoriteWallpaperIds)
      ..writeByte(8)
      ..write(obj.rotateOnlyFavorites)
      ..writeByte(9)
      ..write(obj.lastUpdateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
