// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeMode: fields[0] as String,
      languageCode: fields[1] as String,
      usdRate: fields[2] as double,
      eurRate: fields[3] as double,
      defaultPort: fields[4] as String,
      oceanShippingCost: fields[5] as double,
      portFees: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.languageCode)
      ..writeByte(2)
      ..write(obj.usdRate)
      ..writeByte(3)
      ..write(obj.eurRate)
      ..writeByte(4)
      ..write(obj.defaultPort)
      ..writeByte(5)
      ..write(obj.oceanShippingCost)
      ..writeByte(6)
      ..write(obj.portFees);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
