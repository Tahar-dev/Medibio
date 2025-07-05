import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';

class GetInterventionsById {
  final UserRepository repository;

  GetInterventionsById(this.repository);

  Future<List<InterventionModel>> call(String id) async {
    return await repository.getInterventionsById(id);
  }
}