import 'package:srasav_vf_v1/features/user/data/models/article_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/article.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';

abstract class ParcState {}

class ParcInitial extends ParcState {}
class ParcLoading extends ParcState {}

class ParcLoaded extends ParcState {
  final List<ParcModel> parcs;
  ParcLoaded(this.parcs);
}

class ParcError extends ParcState {
  final String message;

  ParcError(this.message);
}




















class ParcListInitial extends ParcState {}
class ParcListLoading extends ParcState {}

class ParcListLoaded extends ParcState {
  final List<ParcModel> parcsList;

  ParcListLoaded(this.parcsList);
}

class ParcListError extends ParcState {
  final String messageList;

  ParcListError(this.messageList);
}




class ArticleListInitial extends ParcState {}
class ArticleListLoading extends ParcState {}
class ArticleListLoaded extends ParcState {
  final List<ArticleModel> articlesList;

  ArticleListLoaded(this.articlesList);
}


class ArticleListError extends ParcState {
  final String messageArticleList;

  ArticleListError(this.messageArticleList);
}

