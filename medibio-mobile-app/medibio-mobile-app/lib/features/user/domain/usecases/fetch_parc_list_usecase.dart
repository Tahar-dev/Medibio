import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/parc_repository.dart';

class FetchParcsList {
  final ParcRepository repository;

  FetchParcsList({required this.repository});

  Future<List<ParcModel>> call() async {
    return await repository.fetchParcsList();
  }
} 