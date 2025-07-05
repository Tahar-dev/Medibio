import 'dart:ffi';

import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/user_model.dart';

abstract class UserRepository {
  
  Future<UserModel?> login(String email, String password);
  Future<UserModel> getUserById(String id);
  Future<List<InterventionModel>> getInterventionsById(String id);
  Future<List<InterventionModel>> getInterventions(String technicienName);

   Future<void> updateIntervention(String id, Map<String, dynamic> updateData);

   Future<void> updateIntervention2(String id, Map<String, dynamic> updateData);
  
 
}
