import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';

class UpdateIntervention2UseCase {
  final UserRepository repository;

  UpdateIntervention2UseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> updateData) async {
    try {
      await repository.updateIntervention2(id, updateData);
    } catch (e) {
      // Transforme l'erreur si nécessaire (par exemple, en une exception métier)
      throw UpdateInterventionException('Failed to update intervention', e);
    }
  }
}

class UpdateInterventionException implements Exception {
  final String message;
  final dynamic cause;

  UpdateInterventionException(this.message, [this.cause]);

  @override
  String toString() {
    return '$message: $cause';
  }
}
