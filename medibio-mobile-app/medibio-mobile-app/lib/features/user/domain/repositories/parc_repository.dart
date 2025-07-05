import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/article.dart';

import '../entities/parc.dart';

abstract class ParcRepository {
  Future<List<ParcModel>>fetchParcsList();
  Future<List<ArticleModel>>fetchArticleList();
  Future<List<ParcModel>> fetchParcs(String interventionId);
}
