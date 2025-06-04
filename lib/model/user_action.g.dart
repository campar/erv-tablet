// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserActionAdapter extends TypeAdapter<UserAction> {
  @override
  final int typeId = 1;

  @override
  UserAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAction(
      rfid: fields[0] as String,
      actionType: fields[1] as String,
      actionTime: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserAction obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.rfid)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.actionTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
