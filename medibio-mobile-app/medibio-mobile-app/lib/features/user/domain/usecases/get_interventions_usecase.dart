import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';

class GetInterventionsUseCase {
  final UserRepository repository;

  // Constructor accepts UserRepository
  GetInterventionsUseCase({required this.repository});

  // Use case to get interventions by technician name
  Future<List<InterventionModel>> call(String technicienName) async {
    try {
      // Calling the repository to get the data
      final interventions = await repository.getInterventions(technicienName);
      return interventions;  // Returning the list of interventions
    } catch (e) {
      rethrow;  // Propagate any errors
    }
  }
}
