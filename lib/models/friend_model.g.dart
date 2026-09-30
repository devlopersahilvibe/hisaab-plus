// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendModelAdapter extends TypeAdapter<FriendModel> {
  @override
  final int typeId = 1;

  @override
  FriendModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FriendModel(
      name: fields[0] as String,
      phone: fields[1] as String,
      desc: fields[2] as String,
      balance: fields[3] as int,
      type: fields[4] as String,
      lastMessage: fields[5] as String,
      lastDate: fields[6] as String,
      history: (fields[7] as List?)
          ?.map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, FriendModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.desc)
      ..writeByte(3)
      ..write(obj.balance)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.lastMessage)
      ..writeByte(6)
      ..write(obj.lastDate)
      ..writeByte(7)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
