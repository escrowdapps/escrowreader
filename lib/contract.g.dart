// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContractAdapter extends TypeAdapter<Contract> {
  @override
  final int typeId = 2;

  @override
  Contract read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contract(
      fields[1] as String,
      fields[0] as String,
      fields[2] as int,
      (fields[4] as List).cast<dynamic>(),
      (fields[5] as Map).cast<dynamic, dynamic>(),
      fields[6] as dynamic,
      fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Contract obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.days)
      ..writeByte(3)
      ..write(obj.scroll)
      ..writeByte(4)
      ..write(obj.paragraphs)
      ..writeByte(5)
      ..write(obj.walletMap)
      ..writeByte(6)
      ..write(obj.uri);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
