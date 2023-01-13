part of 'picker_bloc.dart';

abstract class PickerEvent extends Equatable {
  const PickerEvent();

  @override
  List<Object> get props => [];
}


class PickerHoursChanged extends PickerEvent {
  const PickerHoursChanged(this.hours);

  final int hours;

  @override
  List<Object> get props => [hours];
}

class PickerMinutesChanged extends PickerEvent {
  const PickerMinutesChanged(this.minutes);

  final int minutes;

  @override
  List<Object> get props => [minutes];
}

class PickerSecondsChanged extends PickerEvent {
  const PickerSecondsChanged(this.seconds);

  final int seconds;

  @override
  List<Object> get props => [seconds];
}