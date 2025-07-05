import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModel user;

  LoginSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure({required this.message});

  @override
  List<Object> get props => [message];
}
