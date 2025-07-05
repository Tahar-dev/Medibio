import 'package:srasav_vf_v1/features/user/data/models/user_model.dart';

import '../repositories/user_repository.dart';


class LoginUseCase {
  final UserRepository userRepository;

  LoginUseCase(this.userRepository);

  Future<UserModel?> execute(String email, String password) async {
    return await userRepository.login(email, password);
  }
}
