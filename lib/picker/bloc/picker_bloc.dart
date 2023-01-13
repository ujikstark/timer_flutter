import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'picker_event.dart';
part 'picker_state.dart';

class PickerBloc extends Bloc<PickerEvent, PickerState> {
  PickerBloc() : super(PickerState()) {
    on<PickerHoursChanged>(_onHoursChanged);
    on<PickerMinutesChanged>(_onMinutesChanged);
    on<PickerSecondsChanged>(_onSecondsChanged);

  }

  int getTimeInSeconds() {
    return (state.hours*3600) + (state.minutes*60) + (state.seconds);
  }

  void _onHoursChanged(PickerHoursChanged event, Emitter<PickerState> emit) {
    emit(state.copyWith(hours: event.hours));
  }

  void _onMinutesChanged(PickerMinutesChanged event, Emitter<PickerState> emit) {
    emit(state.copyWith(minutes: event.minutes));
  }
  void _onSecondsChanged(PickerSecondsChanged event, Emitter<PickerState> emit) {
    emit(state.copyWith(seconds: event.seconds));
  }
}


