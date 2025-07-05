// timer_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  TimerBloc() : super(const TimerInitial(0, 0)) { // Initialisé avec counter=0 et initialTime=0
    on<TimerStarted>(_onTimerStarted);
    on<TimerReset>(_onTimerReset);
    on<TimerIncremented>(_onTimerIncremented);
    on<TimerPaused>(_onTimerPaused);
    on<TimerSetInitial>(_onTimerSetInitial);
  }

  Timer? _timer;
  int _pausedTime = 0;
  int _initialTime = 0; // Nouvelle variable pour stocker le temps initial

  void _onTimerStarted(TimerStarted event, Emitter<TimerState> emit) {
    if (state is TimerPausing) {
      emit(TimerRunning(_pausedTime, _initialTime));
    } else {
      _timer?.cancel();
      emit(TimerRunning(_initialTime, _initialTime)); // Toujours démarrer avec _initialTime
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerIncremented());
    });
  }

  void _onTimerReset(TimerReset event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _pausedTime = 0;
    emit(TimerInitial(_initialTime, _initialTime)); // Réinitialise à la valeur _initialTime
  }

  void _onTimerIncremented(TimerIncremented event, Emitter<TimerState> emit) {
    if (state is TimerRunning) {
      emit(TimerRunning(state.counter + 1, state.initialTime));
    }
  }

  void _onTimerPaused(TimerPaused event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _pausedTime = state.counter;
    emit(TimerPausing(_pausedTime, state.initialTime));
  }

  void _onTimerSetInitial(TimerSetInitial event, Emitter<TimerState> emit) {
    _initialTime = event.initialTime; // Stocke la nouvelle valeur initiale
    emit(TimerInitial(_initialTime, _initialTime));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}