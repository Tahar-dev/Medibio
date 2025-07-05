// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_listarticle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalListArticleAdapter extends TypeAdapter<LocalListArticle> {
  @override
  final int typeId = 4;

  @override
  LocalListArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalListArticle(
      id: fields[0] as String?,
      parcid: fields[1] as String?,
      designation: fields[2] as String?,
      us: fields[3] as String?,
      quantity: fields[4] as String?,
      type: fields[5] as String?,
      ref: fields[6] as String?,
      commentaire: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalListArticle obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.parcid)
      ..writeByte(2)
      ..write(obj.designation)
      ..writeByte(3)
      ..write(obj.us)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.ref)
      ..writeByte(7)
      ..write(obj.commentaire);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalListArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
