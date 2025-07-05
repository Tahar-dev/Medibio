import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/fetch_article_list_usecase.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/fetch_parc_list_usecase.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/fetch_parc_usecase.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_event.dart';
import 'package:srasav_vf_v1/features/user/presentation/blocs/parc/parc_state.dart';

class ParcBloc extends Bloc<ParcEvent, ParcState> {
  final FetchParcs fetchParcs;
  final FetchParcsList fetchParcsList;
  final FetchArticleList fetchArticlesList;
  
  ParcBloc(this.fetchParcsList, this.fetchArticlesList, {required this.fetchParcs}) : super(ParcInitial()) {
    on<LoadParcs>(_onLoadParcs);
    on<LoadAllParcs>(_onLoadAllParcs);
     on<LoadAllArticles>(_onLoadAllArticles);
  }

  Future<void> _onLoadParcs(LoadParcs event, Emitter<ParcState> emit) async {
    emit(ParcLoading());
    try {
      // Pass the intervention ID to the use case
      final parcs = await fetchParcs(event.interventionId);
      emit(ParcLoaded(parcs));
    } catch (e) {
      emit(ParcError('Failed to fetch parcs: $e'));
    }
  }

  Future<void> _onLoadAllParcs(LoadAllParcs event, Emitter<ParcState> emit) async {
    emit(ParcListLoading());
    try {
      final parcsList = await fetchParcsList();
      emit(ParcListLoaded(parcsList));
    } catch (e) {
      emit(ParcListError('Failed to fetch parcs List: $e'));
    }
  }

  Future<void> _onLoadAllArticles(LoadAllArticles event, Emitter<ParcState> emit) async {
  emit(ArticleListLoading());
  try {
    // Utilisez fetchArticlesList pour récupérer les articles
    final articleList = await fetchArticlesList();
    emit(ArticleListLoaded(articleList));
  } catch (e) {
    emit(ArticleListError('Failed to fetch article list: $e'));
  }
}

}
