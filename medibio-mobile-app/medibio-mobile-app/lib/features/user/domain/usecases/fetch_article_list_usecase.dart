import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/article.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/parc_repository.dart';

class FetchArticleList {
  final ParcRepository repository;

  FetchArticleList({required this.repository});

  Future<List<ArticleModel>> call() async {
    return await repository.fetchArticleList();
  }
} 