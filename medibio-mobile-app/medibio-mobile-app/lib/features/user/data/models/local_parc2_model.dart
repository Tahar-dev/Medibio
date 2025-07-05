import 'package:hive/hive.dart';
import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';

part 'local_parc2_model.g.dart';

@HiveType(typeId: 6)
class LocalParc2 extends HiveObject {
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

  LocalParc2({
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

  ParcModel toParcModel() {
  return ParcModel(
    addressSite: this.addressSite,
    article: this.article,
    articles: this.articles?.map((article) => ArticleModel.fromLocalArticle(article)).toList(),
    designation: this.designation,
    designationSite: this.designationSite,
    firmware: this.firmware,
    forced: this.forced,
    id: this.id,
    isSelected: this.isSelected,
    localisation: this.localisation,
    marque: this.marque,
    marqueDesignation: this.marqueDesignation,
    numserie: this.numserie,
    parcHistoryList: this.parcHistoryList,
    report: this.report,
    reportDraft: this.reportDraft,
    reportState: this.reportState,
    software: this.software,
    typeContrat: this.typeContrat,
    resume:this.resume,
    observation:this.observation,

    attitudeApparence: this.attitudeApparence,
    qualityPrestation: this.qualityPrestation,
    communication: this.communication,
    globlement: this.globlement,
    problemType: this.problemType,

    problemTypeList : this.problemTypeList,

    interventions: this.interventions,
    datesInterventions: this.datesInterventions,
    techniciens: this.techniciens,  
    commentaires: this.commentaires,

    intitule: this.intitule,
    codeRapport: this.codeRapport

  );
}

// Convertir un objet Parc en LocalParc2
  /*factory LocalParc2.fromParc(ParcModel parc) {
    return LocalParc2(
      id : parc.id!,
      designation: parc.designation,
      numserie: parc.numserie,
      marque: parc.marque,
      localisation: parc.localisation,
      software: parc.software,
      firmware: parc.firmware,
    );
  }*/
  
  /// Méthode pour convertir un `ParcModel` en JSON
  Map<String, dynamic> toJson() {
    return {
      'addressSite': addressSite,
      'article': article,
      'articles': articles?.map((article) => article.toJson()).toList(),
      'designation': designation,
      'designationSite': designationSite,
      'firmware': firmware,
      'forced': forced,
      'id': id,
      'isSelected': isSelected,
      'localisation': localisation,
      'marque': marque,
      'marque_designation': marqueDesignation,
      'numserie': numserie,
      'parcHistoryList': parcHistoryList,
      'report': report,
      'reportDraft': reportDraft,
      'reportState': reportState,
      'software': software,
      'typeContrat': typeContrat,
      'resume': resume,
      'observation': observation,

      'attitudeApparence': attitudeApparence,
      'qualityPrestation': qualityPrestation,
      'communication': communication,
      'globlement': globlement,
      'problemType': problemType,

      'problemTypeList' : problemTypeList,
      
      'interventions': interventions,
      'datesInterventions': datesInterventions,
      'techniciens': techniciens,
      'commentaires': commentaires,

    'intitule': intitule,
    'codeRapport' : codeRapport


    };
  }
  // Méthode pour créer un ParcModel à partir de LocalParc
  /*ParcModel.fromLocalParc(LocalParc localParc) {
    this.id = localParc.id;
    this.article =localParc.article;
    this.articles =localParc.articles?.map((article) => ArticleModel.fromLocalArticle(article)).toList();
    this.marque = localParc.marque;
    this.numserie = localParc.numserie;
    this.localisation = localParc.localisation;
    this.firmware = localParc.firmware;
    this.software = localParc.software;
    this.marqueDesignation = localParc.marqueDesignation;
    this.designation = localParc.designation;
    this.addressSite = localParc.addressSite;
    this.designationSite = localParc.designationSite;
    this.typeContrat = localParc.typeContrat;
    this.parcHistoryList = localParc.parcHistoryList;
    this.report = localParc.report;
    this.reportDraft = localParc.reportDraft;
    this.reportState = localParc.reportState;
    this.isSelected = localParc.isSelected;
    this.forced = localParc.forced;

    this.resume = localParc.resume;
    this.observation = localParc.observation;
  }*/
}
