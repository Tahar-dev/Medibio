import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';


part 'local_intervention_model.g.dart';

@HiveType(typeId: 3)
class LocalIntervention extends HiveObject {
  @HiveField(0)
  final String? BL;

  @HiveField(1)
  final List<String>? BL_Article;

  @HiveField(2)
  final String? address;

  @HiveField(3)
  final List<String>? articleMissionExpense;

  @HiveField(4)
  final String? calendardate;

  @HiveField(5)
  final String? client;

  @HiveField(6)
  final String? codeaddress;

  @HiveField(7)
  final String? couvertureglobale;

  @HiveField(8)
  final String? date;

  @HiveField(9)
  final String? debuteHour;

  @HiveField(10)
  final String? description;

  @HiveField(11)
  final String? duration;

  @HiveField(12)
  final String? email;

  @HiveField(13)
  final String? enddate;

  @HiveField(14)
  final String? finishHour;

  @HiveField(15)
  final String? id;

  @HiveField(16)
  final List<String>? idParcArray;

  @HiveField(17)
  final String? id_client;

  @HiveField(18)
  final String? interventionId;

  @HiveField(19)
  final bool? isPlanified;

  @HiveField(20)
  final bool? isSaved;

  @HiveField(21)
  final String? lieu;

  @HiveField(22)
  final String? locationLatitude;

  @HiveField(23)
  final String? locationLongitude;

  @HiveField(24)
  final String? mobilestatus;

  @HiveField(25)
  final String? npid;

  @HiveField(26)
  final List<LocalParc>? parcs;

  @HiveField(27)
  final List<String>? pausedChronoDataArray;

  @HiveField(28)
  final String? realdepartureDate;

  @HiveField(29)
  final String? realdepartureTime;

  @HiveField(30)
  final String? realduration;

  @HiveField(31)
  final String? realenddate;

  @HiveField(32)
  final String? realendtime;

  @HiveField(33)
  final String? realstartdate;

  @HiveField(34)
  final String? realstarttime;

  @HiveField(35)
  final List<String>? ressources;

  @HiveField(36)
  final String? satisfaction;

  @HiveField(37)
  final String? state;

  @HiveField(38)
  final String? technicienRealName;

  @HiveField(39)
  final String? technicienname;

  @HiveField(40)
  final String? tel;

  @HiveField(41)
  final String? type;

  @HiveField(42)
  final String? urgency;


  @HiveField(43)
  final String? attitudeApparenceItv;

  @HiveField(44)
  final String?  qualityPrestationItv;

  @HiveField(45)
  final String? communicationItv;

  @HiveField(46)
  final String? globlementItv;

  @HiveField(47)
  final List<String>? realstarttimelist;

  @HiveField(48)
  final List<String>? realendtimelist;


  @HiveField(49)
  final List<String>? realstartdaylist;

  @HiveField(50)
  final List<String>? fcmlisttokens;



  LocalIntervention({
    this.BL,
    this.BL_Article,
    this.address,
    this.articleMissionExpense,
    this.calendardate,
    this.client,
    this.codeaddress,
    this.couvertureglobale,
    this.date,
    this.debuteHour,
    this.description,
    this.duration,
    this.email,
    this.enddate,
    this.finishHour,
    this.id,
    this.idParcArray,
    this.id_client,
    this.interventionId,
    this.isPlanified,
    this.isSaved,
    this.lieu,
    this.locationLatitude,
    this.locationLongitude,
    this.mobilestatus,
    this.npid,
    this.parcs,
    this.pausedChronoDataArray,
    this.realdepartureDate,
    this.realdepartureTime,

    this.realduration,

    this.realenddate,
    this.realendtime,
    this.realstartdate,
    this.realstarttime,


    this.ressources,
    this.satisfaction,
    this.state,
    this.technicienRealName,
    this.technicienname,
    this.tel,
    this.type,
    this.urgency,

    this.attitudeApparenceItv,
    this.communicationItv,
    this.qualityPrestationItv,  
    this.globlementItv, 

    this.realstarttimelist,
    this.realendtimelist,
    this.realstartdaylist,
    this.fcmlisttokens,
    
  });
}
