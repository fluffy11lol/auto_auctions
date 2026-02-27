// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LotModelAdapter extends TypeAdapter<LotModel> {
  @override
  final int typeId = 0;

  @override
  LotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LotModel(
      id: fields[0] as String,
      lotNumber: fields[1] as String,
      auction: fields[2] as String,
      url: fields[3] as String?,
      make: fields[4] as String,
      model: fields[5] as String,
      year: fields[6] as int,
      vin: fields[7] as String?,
      mileage: fields[8] as int?,
      engine: fields[9] as String?,
      transmission: fields[10] as String?,
      drivetrain: fields[11] as String?,
      fuelType: fields[12] as String?,
      exteriorColor: fields[13] as String?,
      currentBid: fields[14] as double,
      buyNowPrice: fields[15] as double?,
      state: fields[16] as String,
      city: fields[17] as String,
      saleDate: fields[18] as DateTime?,
      primaryDamage: fields[19] as String,
      secondaryDamage: fields[20] as String?,
      hasKeys: fields[21] as bool,
      runsDrives: fields[22] as bool,
      titleType: fields[23] as String,
      photos: (fields[24] as List).cast<String>(),
      notes: fields[25] as String?,
      isFavorite: fields[26] as bool,
      createdAt: fields[27] as DateTime,
      updatedAt: fields[28] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LotModel obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lotNumber)
      ..writeByte(2)
      ..write(obj.auction)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.make)
      ..writeByte(5)
      ..write(obj.model)
      ..writeByte(6)
      ..write(obj.year)
      ..writeByte(7)
      ..write(obj.vin)
      ..writeByte(8)
      ..write(obj.mileage)
      ..writeByte(9)
      ..write(obj.engine)
      ..writeByte(10)
      ..write(obj.transmission)
      ..writeByte(11)
      ..write(obj.drivetrain)
      ..writeByte(12)
      ..write(obj.fuelType)
      ..writeByte(13)
      ..write(obj.exteriorColor)
      ..writeByte(14)
      ..write(obj.currentBid)
      ..writeByte(15)
      ..write(obj.buyNowPrice)
      ..writeByte(16)
      ..write(obj.state)
      ..writeByte(17)
      ..write(obj.city)
      ..writeByte(18)
      ..write(obj.saleDate)
      ..writeByte(19)
      ..write(obj.primaryDamage)
      ..writeByte(20)
      ..write(obj.secondaryDamage)
      ..writeByte(21)
      ..write(obj.hasKeys)
      ..writeByte(22)
      ..write(obj.runsDrives)
      ..writeByte(23)
      ..write(obj.titleType)
      ..writeByte(24)
      ..write(obj.photos)
      ..writeByte(25)
      ..write(obj.notes)
      ..writeByte(26)
      ..write(obj.isFavorite)
      ..writeByte(27)
      ..write(obj.createdAt)
      ..writeByte(28)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
