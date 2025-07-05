// timer_event.dart
abstract class TimerEvent {}

class TimerStarted extends TimerEvent {}

class TimerReset extends TimerEvent {}

class TimerIncremented extends TimerEvent {}

class TimerPaused extends TimerEvent {}

class TimerSetInitial extends TimerEvent {
  final int initialTime;
  TimerSetInitial(this.initialTime);
}