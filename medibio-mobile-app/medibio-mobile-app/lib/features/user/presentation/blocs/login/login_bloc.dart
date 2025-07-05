import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;

  LoginBloc(this.loginUseCase) : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginInitial()); // Réinitialiser l'état avant la connexion
      try {
        final user = await loginUseCase.execute(event.email, event.password);
        if (user != null) {
          emit(LoginSuccess(user: user));
        } else {
          emit(LoginFailure(message: "Identifiants invalides"));
        }
      } catch (e) {
        emit(LoginFailure(message: e.toString()));
      }
    });
  }
}
