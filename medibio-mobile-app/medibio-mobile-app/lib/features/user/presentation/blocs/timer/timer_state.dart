// timer_state.dart
abstract class TimerState {
  final int counter;
  final int initialTime;
  const TimerState(this.counter, this.initialTime);
}

class TimerInitial extends TimerState {
  const TimerInitial(int counter, int initialTime) : super(counter, initialTime);
}

class TimerRunning extends TimerState {
  const TimerRunning(int counter, int initialTime) : super(counter, initialTime);
}

class TimerPausing extends TimerState {
  const TimerPausing(int counter, int initialTime) : super(counter, initialTime);
}