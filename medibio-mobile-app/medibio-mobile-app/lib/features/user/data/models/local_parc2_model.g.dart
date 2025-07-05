// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_parc2_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalParc2Adapter extends TypeAdapter<LocalParc2> {
  @override
  final int typeId = 6;

  @override
  LocalParc2 read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalParc2(
      addressSite: fields[0] as String?,
      article: fields[1] as String?,
      articles: (fields[2] as List?)?.cast<LocalArticle>(),
      designation: fields[3] as String?,
      designationSite: fields[4] as String?,
      firmware: fields[5] as String?,
      forced: fields[6] as String?,
      id: fields[7] as String,
      isSelected: fields[8] as bool?,
      localisation: fields[9] as String?,
      marque: fields[10] as String?,
      marqueDesignation: fields[11] as String?,
      numserie: fields[12] as String?,
      parcHistoryList: (fields[13] as List?)?.cast<String>(),
      report: (fields[14] as List?)?.cast<String>(),
      reportDraft: (fields[15] as List?)?.cast<String>(),
      reportState: fields[16] as String?,
      software: fields[17] as String?,
      typeContrat: fields[18] as String?,
      resume: fields[19] as String?,
      observation: fields[20] as String?,
      attitudeApparence: fields[21] as String?,
      qualityPrestation: fields[22] as String?,
      communication: fields[23] as String?,
      globlement: fields[24] as String?,
      problemType: fields[25] as String?,
      problemTypeList: (fields[26] as List?)?.cast<String>(),
      interventions: (fields[29] as List?)?.cast<String>(),
      datesInterventions: (fields[30] as List?)?.cast<String>(),
      techniciens: (fields[31] as List?)?.cast<String>(),
      commentaires: (fields[32] as List?)?.cast<String>(),
      intitule: fields[27] as String?,
      codeRapport: fields[28] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalParc2 obj) {
    writer
      ..writeByte(33)
      ..writeByte(0)
      ..write(obj.addressSite)
      ..writeByte(1)
      ..write(obj.article)
      ..writeByte(2)
      ..write(obj.articles)
      ..writeByte(3)
      ..write(obj.designation)
      ..writeByte(4)
      ..write(obj.designationSite)
      ..writeByte(5)
      ..write(obj.firmware)
      ..writeByte(6)
      ..write(obj.forced)
      ..writeByte(7)
      ..write(obj.id)
      ..writeByte(8)
      ..write(obj.isSelected)
      ..writeByte(9)
      ..write(obj.localisation)
      ..writeByte(10)
      ..write(obj.marque)
      ..writeByte(11)
      ..write(obj.marqueDesignation)
      ..writeByte(12)
      ..write(obj.numserie)
      ..writeByte(13)
      ..write(obj.parcHistoryList)
      ..writeByte(14)
      ..write(obj.report)
      ..writeByte(15)
      ..write(obj.reportDraft)
      ..writeByte(16)
      ..write(obj.reportState)
      ..writeByte(17)
      ..write(obj.software)
      ..writeByte(18)
      ..write(obj.typeContrat)
      ..writeByte(19)
      ..write(obj.resume)
      ..writeByte(20)
      ..write(obj.observation)
      ..writeByte(21)
      ..write(obj.attitudeApparence)
      ..writeByte(22)
      ..write(obj.qualityPrestation)
      ..writeByte(23)
      ..write(obj.communication)
      ..writeByte(24)
      ..write(obj.globlement)
      ..writeByte(25)
      ..write(obj.problemType)
      ..writeByte(26)
      ..write(obj.problemTypeList)
      ..writeByte(27)
      ..write(obj.intitule)
      ..writeByte(28)
      ..write(obj.codeRapport)
      ..writeByte(29)
      ..write(obj.interventions)
      ..writeByte(30)
      ..write(obj.datesInterventions)
      ..writeByte(31)
      ..write(obj.techniciens)
      ..writeByte(32)
      ..write(obj.commentaires);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalParc2Adapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
