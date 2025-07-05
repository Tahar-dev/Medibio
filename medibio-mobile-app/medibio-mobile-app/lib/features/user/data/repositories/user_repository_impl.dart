import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import '../data_sources/user_remote_data_source.dart';
import '../models/user_model.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  
  UserRepositoryImpl({UserRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? UserRemoteDataSource();

    @override
  Future<UserModel?> login(String email, String password) async {
    return await remoteDataSource.login(email, password); 
  }

    @override
  Future<UserModel> getUserById(String id) async {
    return await remoteDataSource.getUserById(id);
  }
  
@override
  Future<List<InterventionModel>> getInterventionsById(String id) async {
 
    return await remoteDataSource.getInterventionsById(id);
  }

  @override
  Future<void> updateIntervention(String id, Map<String, dynamic> updateData) async {
    try {
      await remoteDataSource.updateIntervention(id, updateData);
    } catch (e) {
      throw Exception('Error in repository: $e');
    }
  }

    @override
  Future<void> updateIntervention2(String id, Map<String, dynamic> updateData) async {
    try {
      await remoteDataSource.updateIntervention2(id, updateData);
    } catch (e) {
      throw Exception('Error in repository: $e');
    }
  }
  
  @override
  Future<List<InterventionModel>> getInterventions(String technicienName) async {
    final interventionModels = await remoteDataSource.getInterventions(technicienName);
    return interventionModels.map((model) => model).toList();
  }
}
