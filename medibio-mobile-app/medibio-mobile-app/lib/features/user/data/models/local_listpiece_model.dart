import 'package:hive/hive.dart';

part 'local_listpiece_model.g.dart';

@HiveType(typeId: 5)
class LocalPieceArticle extends HiveObject {



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



  LocalPieceArticle({
    this.id,
    this.parcid,
    this.designation,
    this.us,
    this.quantity,
    this.type,
    this.ref,
    this.commentaire
  });
}
