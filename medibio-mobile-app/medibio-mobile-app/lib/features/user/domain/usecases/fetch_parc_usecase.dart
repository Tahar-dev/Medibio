import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';

import '../entities/parc.dart';
import '../repositories/parc_repository.dart';

class FetchParcs {
  final ParcRepository repository;

  FetchParcs({required this.repository});

  /// Executes the use case to fetch parcs based on the intervention ID.
  Future<List<ParcModel>> call(String interventionId) async {
    return await repository.fetchParcs(interventionId);
  }
}
