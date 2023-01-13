part of 'picker_bloc.dart';

class PickerState extends Equatable {
  const PickerState({
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  });

  final int hours;
  final int minutes;
  final int seconds;

  PickerState copyWith({
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return PickerState(
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }

  @override
  String toString() {
    return '''PickerState { hours: $hours, minutes: $minutes, seconds: $seconds} }''';
  }

  @override
  List<Object> get props => [hours, minutes, seconds];
}
