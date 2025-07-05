import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:srasav_vf_v1/features/user/data/models/intervention_model.dart';
import 'package:srasav_vf_v1/features/user/data/models/parc_model.dart';
import 'package:srasav_vf_v1/features/user/domain/entities/parc.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/get_interventions_by_id_usecase.dart';
import 'package:srasav_vf_v1/features/user/domain/usecases/update_intervention_usecase.dart';
import 'intervention_event.dart';
import 'intervention_state.dart';

class InterventionBloc extends Bloc<InterventionEvent, InterventionState> {
  final GetInterventionsById getInterventionsById;
  InterventionModel? _selectedIntervention;

  InterventionBloc(this.getInterventionsById) : super(InterventionInitial()) {

    on<GetInterventionsByIdEvent>((event, emit) async {
      emit(InterventionLoading());
      try {
        final interventions = await getInterventionsById(event.id);
        emit(InterventionLoaded(interventions: interventions));
      } catch (e) {
        emit(InterventionError(message: e.toString()));
      }
    });

  on<SelectIntervention>((event, emit) {
  _selectedIntervention = event.intervention;
  emit(InterventionSelected(selecteditv: event.intervention));
  print("Intervention selected: ${event.intervention}");
});


    on<AddParcIdEvent>((event, emit) {
      if (_selectedIntervention != null) {
        final List<ParcModel> updatedParcIds = List.from(_selectedIntervention!.parcs as Iterable)
          ..add(event.parcId);

        _selectedIntervention!.parcs = updatedParcIds;
        emit(InterventionSelected(selecteditv: _selectedIntervention!));
      } else {
        emit(InterventionError(message: "Aucune intervention sélectionnée."));
      }
    });

on<UpdateInterventionEvent>((event, emit) async {
 emit(InterventionLoading());
  try {
    // Appel de l'API via le repository
    await event.repository.updateIntervention(
      event.id,
      event.updateData,
    );
    emit(InterventionSelected(selecteditv: _selectedIntervention!));
  } catch (e) {
    // Renvoyer une erreur détaillée dans l'état
   // emit(InterventionError(message: e.toString()));
    //emit(InterventionSelected(selecteditv: _selectedIntervention!));
  }
});

on<UpdateIntervention2Event>((event, emit) async {
 emit(InterventionLoading());
  try {
    // Appel de l'API via le repository
    await event.repository.updateIntervention2(
      event.id,
      event.updateData,
    );
    emit(InterventionSelected(selecteditv: _selectedIntervention!));
  } catch (e) {
    // Renvoyer une erreur détaillée dans l'état
   // emit(InterventionError(message: e.toString()));
    //emit(InterventionSelected(selecteditv: _selectedIntervention!));
  }
});



  }

  InterventionModel? get selectedIntervention => _selectedIntervention;
}
