import 'package:equatable/equatable.dart';
import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';


abstract class InterventionState extends Equatable {
  const InterventionState();

  @override
  List<Object?> get props => [];
}

class InterventionInitial extends InterventionState {}

class InterventionLoading extends InterventionState {}

class InterventionLoaded extends InterventionState {

  final List<InterventionModel> interventions;

  InterventionLoaded({required this.interventions});

  @override
  List<Object?> get props => [interventions];
}



class InterventionSelected extends InterventionState {
  final InterventionModel selecteditv;

  InterventionSelected({required this.selecteditv});

  @override
  List<Object?> get props => [selecteditv];
}



class InterventionError extends InterventionState {
  final String message;

  InterventionError({required this.message});

  @override
  List<Object?> get props => [message];
}


