import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';

part 'local_parc_model.g.dart';

@HiveType(typeId: 2)
class LocalParc extends HiveObject {
  @HiveField(0)
  final String? addressSite;

  @HiveField(1)
  final String? article;

  @HiveField(2)
  final List<LocalArticle>? articles;

  @HiveField(3)
  final String? designation;

  @HiveField(4)
  final String? designationSite;

  @HiveField(5)
  final String? firmware;

  @HiveField(6)
  final String? forced;

  @HiveField(7)
  final String id;

  @HiveField(8)
  final bool? isSelected;

  @HiveField(9)
  final String? localisation;

  @HiveField(10)
  final String? marque;

  @HiveField(11)
  final String? marqueDesignation;

  @HiveField(12)
  final String? numserie;

  @HiveField(13)
  final List<String>? parcHistoryList;

  @HiveField(14)
  final List<String>? report;

  @HiveField(15)
  final List<String>? reportDraft;

  @HiveField(16)
  final String? reportState;

  @HiveField(17)
  final String? software;

  @HiveField(18)
  final String? typeContrat;

  @HiveField(19)
  final String? resume;

  @HiveField(20)
  final String? observation;

  @HiveField(21)
  final String? attitudeApparence;

  @HiveField(22)
  final String? qualityPrestation;

  @HiveField(23)
  final String? communication;

  @HiveField(24)
  final String? globlement;

  @HiveField(25)
  final String? problemType;

  @HiveField(26)
  final List<String>? problemTypeList;



  @HiveField(27)
  final String? intitule;

  @HiveField(28)
  final String?  codeRapport;

  @HiveField(29)
  final List<String>?  interventions;

  @HiveField(30)
  final List<String>?  datesInterventions;

  @HiveField(31)
  final List<String>?  techniciens;

  @HiveField(32)
  final List<String>?  commentaires;

  

  LocalParc({
    this.addressSite,
    this.article,
    this.articles,
    this.designation,
    this.designationSite,
    this.firmware,
    this.forced,
    required this.id,
    this.isSelected,
    this.localisation,
    this.marque,
    this.marqueDesignation,
    this.numserie,
    this.parcHistoryList,
    this.report,
    this.reportDraft,
    this.reportState,
    this.software,
    this.typeContrat,

    this.resume,
    this.observation,

    this.attitudeApparence,
    this.qualityPrestation,
    this.communication,
    this.globlement,
    this.problemType,

    this.problemTypeList,
    
    this.interventions, 
    this.datesInterventions,
    this.techniciens,
    this.commentaires,

    this.intitule,
    this.codeRapport

  });

  
}
