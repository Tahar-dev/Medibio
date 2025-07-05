import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'article.dart';

class Parc {
  String? addressSite;
  String? article;
  List<ArticleModel>? articles;
  String? designation;
  String? designationSite;
  String? firmware;
  String? forced;
  String? id;
  bool? isSelected;
  String? localisation;
  String? marque;
  String? marqueDesignation;
  String? numserie; 
  List<String>? parcHistoryList;
  List<String>? report;
  List<String>? reportDraft;
  String? reportState;
  String? software;
  String? typeContrat;

  String? resume;
  String? observation;

  // attitudeApparence - qualityPrestation - communication - globlement ---- problemType

  String? attitudeApparence ;
  String?  qualityPrestation ;
  String? communication;

  String? globlement ;
  String?  problemType;

  Parc({
    this.addressSite,
    this.article,
    this.articles,
    this.designation,
    this.designationSite,
    this.firmware,
    this.forced,
    this.id,
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
  });
}
