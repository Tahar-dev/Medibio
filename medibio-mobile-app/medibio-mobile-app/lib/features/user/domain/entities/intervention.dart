import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';

class Intervention {
  String? BL;

  List<String>? BL_Article; 

  String? address;

  List<String>? articleMissionExpense;

  List<String>? fcmlisttokens;

  String? calendardate;

  String? client;

  String? codeaddress;

  String? couvertureglobale;

  String? date;

  String? debuteHour;

  String? description;

  String? duration;

  String? email;

  String? enddate; 

  String? finishHour;

  String? id;

  List<String>? idParcArray;

  String? id_client;

  String? interventionId;

  bool? isPlanified;

  bool? isSaved;

  String? lieu;

  String? locationLatitude;

  String? locationLongitude;

  String? mobilestatus;

  String? npid; 

  List<ParcModel>? parcs;

  List<String>? pausedChronoDataArray; 

  String? realdepartureDate; 

  String? realdepartureTime; 

  String? realduration; 

  String? realenddate; 

  String? realendtime; 

  String? realstartdate; 

  String? realstarttime;

  List<String>? ressources; 

  String? satisfaction;

  String? state;

  String? technicienRealName;

  String? technicienname;

  String? tel;

  String? type;

  String? urgency;

  Intervention({
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
    this.fcmlisttokens
  });



}
