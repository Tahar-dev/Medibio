import 'package:srasav_vf_v1/features/user/data/models/user_model.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';

class GetUserById {

  final UserRepository userRepository;
  GetUserById(this.userRepository);
  Future<UserModel> call(String id) async {
    return await userRepository.getUserById(id);
  }
  
}
