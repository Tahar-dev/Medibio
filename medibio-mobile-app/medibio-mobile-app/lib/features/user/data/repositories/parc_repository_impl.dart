import 'package:srasav_vf_v1/features/user/data/data_sources/user_remote_data_source.dart';
import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/article.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/parc_repository.dart';

import '../../domain/entities/parc.dart';

class ParcRepositoryImpl implements ParcRepository {
  final UserRemoteDataSource remoteDataSource;

  ParcRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ParcModel>> fetchParcs(String interventionId) async {
    return await remoteDataSource.fetchParcs(interventionId);
  }

    @override
  Future<List<ParcModel>> fetchParcsList() async {
    return await remoteDataSource.fetchParcsList();
  }

    @override
  Future<List<ArticleModel>> fetchArticleList() async {
  return await remoteDataSource.fetchArticleList();
  }
}

