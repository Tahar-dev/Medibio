import 'package:srasav_vf_v1/features/user/data/models/local_article_model.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  String? id;
  String? parcid;
  String? designation;
  String? us;
  String? quantity;
  String? type;

  String? ref;
  String? commentaire;

  ArticleModel({
    this.id,
    this.parcid,
    this.designation,
    this.us,
    this.quantity,
    this.type,

    this.ref,
    this.commentaire,
  });

  /// Méthode pour créer un `ArticleModel` à partir d'un JSON
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      parcid: json['parcid'],
      designation: json['designation'],
      us: json['us'],
      quantity: json['quantity'],
      type: json['type'],
      ref: json['ref'],
      commentaire: json['commentaire'],
    );
  }

  /// Méthode pour convertir un `ArticleModel` en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcid': parcid,
      'designation': designation,
      'us': us,
      'quantity': quantity,
      'type': type,
      'ref':ref,
      'commenataire':commentaire
    };
  }

  /// Méthode pour créer un `ArticleModel` à partir d'un `LocalArticle`
  ArticleModel.fromLocalArticle(LocalArticle localArticle) {
    id = localArticle.id;
    parcid = localArticle.parcid;
    designation = localArticle.designation;
    us = localArticle.us;
    quantity = localArticle.quantity;
    type = localArticle.type;
    ref=localArticle.ref;
    commentaire=localArticle.commentaire;
  }

  /// Méthode pour convertir un `ArticleModel` en `LocalArticle`
  LocalArticle toLocalArticle() {
    return LocalArticle(
      id: id,
      parcid: parcid,
      designation: designation,
      us: us,
      quantity: quantity,
      type: type,
      ref:ref,
      commentaire:commentaire,
    );
  }
}
