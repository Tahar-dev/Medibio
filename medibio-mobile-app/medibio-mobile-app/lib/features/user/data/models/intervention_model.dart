import 'package:srasav_vf_v1/features/user/data/models/local_intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/intervention.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';

class InterventionModel extends Intervention {

  String? BL;
  List<String>? BL_Article;
  String? address;
  List<String>? articleMissionExpense;
  List<String>?fcmlisttokens;
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
  List<ParcModel>? parcs ;
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

  String? attitudeApparenceItv ;
  String?  qualityPrestationItv ;
  String? communicationItv;
  String? globlementItv ;

  List<String>? realstarttimelist;
  List<String>? realendtimelist;

  List<String>?realstartdaylist;


  

  InterventionModel({
    this.BL,
    this.BL_Article,
    this.address,
    this.articleMissionExpense,
    this.fcmlisttokens,
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
    this.globlementItv,
    this.qualityPrestationItv,

    this.realstarttimelist,
    this.realendtimelist,

    this.realstartdaylist
  });

  factory InterventionModel.fromJson(Map<String, dynamic> json) {
    return InterventionModel(
      BL: json['BL'],
      BL_Article: json['BL_Article'] != null ? List<String>.from(json['BL_Article']) : null,
      address: json['address'],
      articleMissionExpense: json['articleMissionExpense'] != null
          ? List<String>.from(json['articleMissionExpense'])
          : null,
      fcmlisttokens: json['fcmlisttokens'] != null
          ? List<String>.from(json['fcmlisttokens'])
          : null,
      calendardate: json['calendardate'],
      client: json['client'],
      codeaddress: json['codeaddress'],
      couvertureglobale: json['couvertureglobale'],
      date: json['date'],
      debuteHour: json['debuteHour'],
      description: json['description'],
      duration: json['duration'],
      email: json['email'],
      enddate: json['enddate'],
      finishHour: json['finishHour'],
      id: json['id'],
      idParcArray: json['idParcArray'] != null ? List<String>.from(json['idParcArray']) : null,
      id_client: json['id_client'],
      interventionId: json['interventionId'],
      isPlanified: json['isPlanified'],
      isSaved: json['isSaved'],
      lieu: json['lieu'],
      locationLatitude: json['locationLatitude'],
      locationLongitude: json['locationLongitude'],
      mobilestatus: json['mobilestatus'],
      npid: json['npid'],
      parcs: json['parcs'] != null
          ? (json['parcs'] as List).map((parc) => ParcModel.fromJson(parc)).toList()
          : null,
      pausedChronoDataArray: json['pausedChronoDataArray'] != null
          ? List<String>.from(json['pausedChronoDataArray'])
          : null,
      realdepartureDate: json['realdepartureDate'],
      realdepartureTime: json['realdepartureTime'],
      realduration: json['realduration'],
      realenddate: json['realenddate'],
      realendtime: json['realendtime'],
      realstartdate: json['realstartdate'],
      realstarttime: json['realstarttime'],
      ressources: List<String>.from(json['ressources']),
      satisfaction: json['satisfaction'],
      state: json['state'],
      technicienRealName: json['technicienRealName'],
      technicienname: json['technicienname'],
      tel: json['tel'],
      type: json['type'],
      urgency: json['urgency'],

      attitudeApparenceItv: json['attitudeApparenceItv'],
      qualityPrestationItv: json['qualityPrestationItv'],
      communicationItv: json['communicationItv'],
      globlementItv: json['globlementItv'], 




    //realstarttimelist
    //realendtimelist

    //realstartdaylist

    realstarttimelist: List<String>.from(json['realstarttimelist']),

    realendtimelist: List<String>.from(json['realendtimelist']),
    
    realstartdaylist:List<String>.from(json['realstartdaylist'])



      
   
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BL': BL,
      'BL_Article': BL_Article,
      'address': address,
      'articleMissionExpense': articleMissionExpense,
      'fcmlisttokens': fcmlisttokens,
      'calendardate': calendardate,
      'client': client,
      'codeaddress': codeaddress,
      'couvertureglobale': couvertureglobale,
      'date': date,
      'debuteHour': debuteHour,
      'description': description,
      'duration': duration,
      'email': email,
      'enddate': enddate,
      'finishHour': finishHour,
      'id': id,
      'idParcArray': idParcArray,
      'id_client': id_client,
      'interventionId': interventionId,
      'isPlanified': isPlanified,
      'isSaved': isSaved,
      'lieu': lieu,
      'locationLatitude': locationLatitude,
      'locationLongitude': locationLongitude,
      'mobilestatus': mobilestatus,
      'npid': npid,
      'parcs': parcs?.map((parc) => parc.toJson()).toList(),
      'pausedChronoDataArray': pausedChronoDataArray,
      'realdepartureDate': realdepartureDate,
      'realdepartureTime': realdepartureTime,
      'realduration': realduration,
      'realenddate': realenddate,
      'realendtime': realendtime,
      'realstartdate': realstartdate,
      'realstarttime': realstarttime,
      'ressources': ressources,
      'satisfaction': satisfaction,
      'state': state,
      'technicienRealName': technicienRealName,
      'technicienname': technicienname,
      'tel': tel,
      'type': type,
      'urgency': urgency,

      'attitudeApparenceItv':attitudeApparenceItv,
      'qualityPrestationItv':qualityPrestationItv,
      'communicationItv':communicationItv,
      'globlementItv':globlementItv,
      
    //realstarttimelist
    //realendtimelist

    //realstartdaylist

    'realstarttimelist': realstarttimelist,
    'realendtimelist':realendtimelist,

    'realstartdaylist':realstartdaylist
    };
  }

  // Conversion method from LocalIntervention to InterventionModel
  static InterventionModel fromLocalIntervention(LocalIntervention localIntervention) {
    return InterventionModel(
      BL: localIntervention.BL,
      BL_Article: localIntervention.BL_Article,
      address: localIntervention.address,
      articleMissionExpense: localIntervention.articleMissionExpense,
      fcmlisttokens: localIntervention.fcmlisttokens,
      calendardate: localIntervention.calendardate,
      client: localIntervention.client,
      codeaddress: localIntervention.codeaddress,
      couvertureglobale: localIntervention.couvertureglobale,
      date: localIntervention.date,
      debuteHour: localIntervention.debuteHour,
      description: localIntervention.description,
      duration: localIntervention.duration,
      email: localIntervention.email,
      enddate: localIntervention.enddate,
      finishHour: localIntervention.finishHour,
      id: localIntervention.id,
      idParcArray: localIntervention.idParcArray,
      id_client: localIntervention.id_client,
      interventionId: localIntervention.interventionId,
      isPlanified: localIntervention.isPlanified,
      isSaved: localIntervention.isSaved,
      lieu: localIntervention.lieu,
      locationLatitude: localIntervention.locationLatitude,
      locationLongitude: localIntervention.locationLongitude,
      mobilestatus: localIntervention.mobilestatus,
      npid: localIntervention.npid,
      parcs: localIntervention.parcs?.map((parc) => ParcModel.fromLocalParc(parc)).toList(),
      pausedChronoDataArray: localIntervention.pausedChronoDataArray,
      realdepartureDate: localIntervention.realdepartureDate,
      realdepartureTime: localIntervention.realdepartureTime,
      realduration: localIntervention.realduration,
      realenddate: localIntervention.realenddate,
      realendtime: localIntervention.realendtime,
      realstartdate: localIntervention.realstartdate,
      realstarttime: localIntervention.realstarttime,
      ressources: localIntervention.ressources,
      satisfaction: localIntervention.satisfaction,
      state: localIntervention.state,
      technicienRealName: localIntervention.technicienRealName,
      technicienname: localIntervention.technicienname,
      tel: localIntervention.tel,
      type: localIntervention.type,
      urgency: localIntervention.urgency,
      
      attitudeApparenceItv: localIntervention.attitudeApparenceItv,
      qualityPrestationItv: localIntervention.qualityPrestationItv,
      communicationItv: localIntervention.communicationItv,
      globlementItv: localIntervention.globlementItv,
      
    //realstarttimelist
    //realendtimelist
    

    //realstartdaylist

    realstarttimelist:localIntervention.realstarttimelist,
    realendtimelist:localIntervention.realendtimelist,

    realstartdaylist:localIntervention.realstartdaylist




    );
  }
}
