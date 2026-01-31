// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fish_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FishItemAdapter extends TypeAdapter<FishItem> {
  @override
  final int typeId = 0;

  @override
  FishItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FishItem(
      id: fields[0] as String,
      name: fields[1] as String,
      pricePerKg: fields[2] as double,
      imagePath: fields[3] as String?,
      isActive: fields[4] as bool,
      nameEn: fields[5] as String?,
      nameDe: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FishItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.pricePerKg)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.nameEn)
      ..writeByte(6)
      ..write(obj.nameDe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FishItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
