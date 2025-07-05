import 'package:equatable/equatable.dart';
import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';
import 'package:srasav_vf_v1/features/user/domain/repositories/user_repository.dart';

abstract class InterventionEvent extends Equatable {
  const InterventionEvent();
  @override
  List<Object?> get props => [];
}

class GetInterventionsByIdEvent extends InterventionEvent {
  final String id;

  GetInterventionsByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SelectIntervention extends InterventionEvent {
  final InterventionModel intervention;

  SelectIntervention(this.intervention);

  @override
  List<Object?> get props => [intervention];
}

class AddParcIdEvent extends InterventionEvent {
  final ParcModel parcId;

  AddParcIdEvent({required this.parcId});
}

class UpdateInterventionEvent extends InterventionEvent {
  final String id;
  final Map<String, Object> updateData;
  final UserRepository repository;

  UpdateInterventionEvent({
    required this.id,
    required this.updateData,
    required this.repository,
  });
}

class UpdateIntervention2Event extends InterventionEvent {
  final String id;
  final Map<String, Object> updateData;
  final UserRepository repository;

  UpdateIntervention2Event({
    required this.id,
    required this.updateData,
    required this.repository,
  });
}

