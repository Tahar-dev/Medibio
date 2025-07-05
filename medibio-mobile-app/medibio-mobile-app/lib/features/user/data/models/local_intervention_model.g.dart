// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_intervention_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalInterventionAdapter extends TypeAdapter<LocalIntervention> {
  @override
  final int typeId = 3;

  @override
  LocalIntervention read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalIntervention(
      BL: fields[0] as String?,
      BL_Article: (fields[1] as List?)?.cast<String>(),
      address: fields[2] as String?,
      articleMissionExpense: (fields[3] as List?)?.cast<String>(),
      calendardate: fields[4] as String?,
      client: fields[5] as String?,
      codeaddress: fields[6] as String?,
      couvertureglobale: fields[7] as String?,
      date: fields[8] as String?,
      debuteHour: fields[9] as String?,
      description: fields[10] as String?,
      duration: fields[11] as String?,
      email: fields[12] as String?,
      enddate: fields[13] as String?,
      finishHour: fields[14] as String?,
      id: fields[15] as String?,
      idParcArray: (fields[16] as List?)?.cast<String>(),
      id_client: fields[17] as String?,
      interventionId: fields[18] as String?,
      isPlanified: fields[19] as bool?,
      isSaved: fields[20] as bool?,
      lieu: fields[21] as String?,
      locationLatitude: fields[22] as String?,
      locationLongitude: fields[23] as String?,
      mobilestatus: fields[24] as String?,
      npid: fields[25] as String?,
      parcs: (fields[26] as List?)?.cast<LocalParc>(),
      pausedChronoDataArray: (fields[27] as List?)?.cast<String>(),
      realdepartureDate: fields[28] as String?,
      realdepartureTime: fields[29] as String?,
      realduration: fields[30] as String?,
      realenddate: fields[31] as String?,
      realendtime: fields[32] as String?,
      realstartdate: fields[33] as String?,
      realstarttime: fields[34] as String?,
      ressources: (fields[35] as List?)?.cast<String>(),
      satisfaction: fields[36] as String?,
      state: fields[37] as String?,
      technicienRealName: fields[38] as String?,
      technicienname: fields[39] as String?,
      tel: fields[40] as String?,
      type: fields[41] as String?,
      urgency: fields[42] as String?,
      attitudeApparenceItv: fields[43] as String?,
      communicationItv: fields[45] as String?,
      qualityPrestationItv: fields[44] as String?,
      globlementItv: fields[46] as String?,
      realstarttimelist: (fields[47] as List?)?.cast<String>(),
      realendtimelist: (fields[48] as List?)?.cast<String>(),
      realstartdaylist: (fields[49] as List?)?.cast<String>(),
      fcmlisttokens: (fields[50] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalIntervention obj) {
    writer
      ..writeByte(51)
      ..writeByte(0)
      ..write(obj.BL)
      ..writeByte(1)
      ..write(obj.BL_Article)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.articleMissionExpense)
      ..writeByte(4)
      ..write(obj.calendardate)
      ..writeByte(5)
      ..write(obj.client)
      ..writeByte(6)
      ..write(obj.codeaddress)
      ..writeByte(7)
      ..write(obj.couvertureglobale)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.debuteHour)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.duration)
      ..writeByte(12)
      ..write(obj.email)
      ..writeByte(13)
      ..write(obj.enddate)
      ..writeByte(14)
      ..write(obj.finishHour)
      ..writeByte(15)
      ..write(obj.id)
      ..writeByte(16)
      ..write(obj.idParcArray)
      ..writeByte(17)
      ..write(obj.id_client)
      ..writeByte(18)
      ..write(obj.interventionId)
      ..writeByte(19)
      ..write(obj.isPlanified)
      ..writeByte(20)
      ..write(obj.isSaved)
      ..writeByte(21)
      ..write(obj.lieu)
      ..writeByte(22)
      ..write(obj.locationLatitude)
      ..writeByte(23)
      ..write(obj.locationLongitude)
      ..writeByte(24)
      ..write(obj.mobilestatus)
      ..writeByte(25)
      ..write(obj.npid)
      ..writeByte(26)
      ..write(obj.parcs)
      ..writeByte(27)
      ..write(obj.pausedChronoDataArray)
      ..writeByte(28)
      ..write(obj.realdepartureDate)
      ..writeByte(29)
      ..write(obj.realdepartureTime)
      ..writeByte(30)
      ..write(obj.realduration)
      ..writeByte(31)
      ..write(obj.realenddate)
      ..writeByte(32)
      ..write(obj.realendtime)
      ..writeByte(33)
      ..write(obj.realstartdate)
      ..writeByte(34)
      ..write(obj.realstarttime)
      ..writeByte(35)
      ..write(obj.ressources)
      ..writeByte(36)
      ..write(obj.satisfaction)
      ..writeByte(37)
      ..write(obj.state)
      ..writeByte(38)
      ..write(obj.technicienRealName)
      ..writeByte(39)
      ..write(obj.technicienname)
      ..writeByte(40)
      ..write(obj.tel)
      ..writeByte(41)
      ..write(obj.type)
      ..writeByte(42)
      ..write(obj.urgency)
      ..writeByte(43)
      ..write(obj.attitudeApparenceItv)
      ..writeByte(44)
      ..write(obj.qualityPrestationItv)
      ..writeByte(45)
      ..write(obj.communicationItv)
      ..writeByte(46)
      ..write(obj.globlementItv)
      ..writeByte(47)
      ..write(obj.realstarttimelist)
      ..writeByte(48)
      ..write(obj.realendtimelist)
      ..writeByte(49)
      ..write(obj.realstartdaylist)
      ..writeByte(50)
      ..write(obj.fcmlisttokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalInterventionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
