import 'package:flutter/material.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc2_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/local_parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';

import 'article_model.dart';


class ParcModel extends Parc {
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


    // attitudeApparence - qualityPrestation - communication - globlement ---- problemType --- problemTypeList

  String? attitudeApparence ;
  String?  qualityPrestation ;
  String? communication;
  String? globlement ;
  
  String?  problemType;

  List<String>? problemTypeList;

  String? intitule ; 

  String? codeRapport ; 


List<String>? interventions;

List<String>? datesInterventions;

List<String>? techniciens;

List<String>? commentaires;


  ParcModel({
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

    this.problemTypeList,

    

    this.intitule, 

    this.codeRapport,

    
  this.interventions,
  this.datesInterventions,
  this.techniciens,
  this.commentaires,
  });

  /// Méthode pour créer un `ParcModel` à partir d'un JSON
  factory ParcModel.fromJson(Map<String, dynamic> json) {
    return ParcModel(
      addressSite: json['addressSite'],
      article: json['article'],
      articles: json['articles'] != null
          ? (json['articles'] as List)
              .map((article) => ArticleModel.fromJson(article))
              .toList()
          : null,
      designation: json['designation'],
      designationSite: json['designationSite'],
      firmware: json['firmware'],
      forced: json['forced'],
      id: json['id'],
      isSelected: json['isSelected'],
      localisation: json['localisation'],
      marque: json['marque'],
      marqueDesignation: json['marque_designation'],
      numserie: json['numserie'],
      parcHistoryList: json['parcHistoryList'] != null
          ? List<String>.from(json['parcHistoryList'])
          : null,
      report: json['report'] != null ? List<String>.from(json['report']) : null,
      reportDraft: json['reportDraft'] != null
          ? List<String>.from(json['reportDraft'])
          : null,
      reportState: json['reportState'],
      software: json['software'],
      typeContrat: json['typeContrat'],
      resume: json['resume'],
      observation: json['observation'],

      attitudeApparence: json['attitudeApparence'],
      qualityPrestation: json['qualityPrestation'],
      communication: json['communication'], 
      globlement: json['globlement'],
      problemType: json['problemType'],

      problemTypeList: json['problemTypeList'] != null ? List<String>.from(json['problemTypeList']) : null,

      interventions: json['interventions'] != null ? List<String>.from(json['interventions']) : null,
      datesInterventions: json['datesInterventions'] != null ? List<String>.from(json['datesInterventions']) : null,
      techniciens: json['techniciens'] != null ? List<String>.from(json['techniciens']) : null,
      commentaires: json['commentaires'] != null ? List<String>.from(json['commentaires']) : null,

      /**
    intitule, 
    codeRapport 
    */

      intitule: json['intitule'],
      codeRapport : json['codeRapport'],

    );
  }

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
      'problemTypeList':problemTypeList,

      'interventions': interventions,
      'datesInterventions': datesInterventions,
      'techniciens': techniciens,
      'commentaires': commentaires,

      /**
    intitule, 
    codeRapport 
    */

      'intitule': intitule,
      'codeRapport ': codeRapport,
      
    };
  }
  // Méthode pour créer un ParcModel à partir de LocalParc
  ParcModel.fromLocalParc(LocalParc localParc) {
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

    this.attitudeApparence = localParc.attitudeApparence;
    this.qualityPrestation = localParc.qualityPrestation;
    this.communication = localParc.communication;
    this.globlement = localParc.globlement;
    this.problemType = localParc.problemType;

    this.problemTypeList = localParc.problemTypeList;

    this.interventions = localParc.interventions;
    this.datesInterventions = localParc.datesInterventions;
    this.techniciens = localParc.techniciens;
    this.commentaires = localParc.commentaires;

 

    this.intitule = localParc.intitule;

    this.codeRapport = localParc.codeRapport;

  }


  
  LocalParc toLocalParc() {
  return LocalParc(
    addressSite: this.addressSite,
    article: this.article,
    articles: this.articles?.map((article) => article.toLocalArticle()).toList(),
    designation: this.designation,
    designationSite: this.designationSite,
    firmware: this.firmware,
    forced: this.forced,
    id: this.id ?? '',
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
datesInterventions:this.datesInterventions,
techniciens:this.techniciens,
commentaires:this.commentaires,



    intitule: this.intitule,

    codeRapport  : this.codeRapport 
    
  );
}

  LocalParc2 toLocalParc2() {
  return LocalParc2(
    addressSite: this.addressSite,
    article: this.article,
    articles: this.articles?.map((article) => article.toLocalArticle()).toList(),
    designation: this.designation,
    designationSite: this.designationSite,
    firmware: this.firmware,
    forced: this.forced,
    id: this.id ?? '',
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

    problemTypeList:this.problemTypeList,


    interventions: this.interventions,
    datesInterventions:this.datesInterventions,
    techniciens:this.techniciens,
    commentaires:this.commentaires,


    intitule: this.intitule,

    codeRapport:this.codeRapport,
    
  );
}

}

