import 'package:hive/hive.dart';

part 'local_article_model.g.dart';

@HiveType(typeId: 1)
class LocalArticle extends HiveObject {

  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? parcid;

  @HiveField(2)
  final String? designation;

  @HiveField(3)
  final String? us;

  @HiveField(4)
  final String? quantity;

  @HiveField(5)
  final String? type;

  @HiveField(6)
  final String? ref;

  @HiveField(7)
  final String? commentaire;





  LocalArticle({
    this.id,
    this.parcid,
    this.designation,
    this.us,
    this.quantity,
    this.type,
    this.ref,
    this.commentaire
  });


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
      'commentaire':commentaire 
    };
  }
}
