
import 'package:bloc/bloc.dart';

class PickerCubit extends Cubit<Map<String, dynamic>> {
  PickerCubit() : super({"hours": 0, "minutes": 0, "seconds": 0});
  
  void setHours(int hours) {
    emit({
      "hours": hours,
      "minutes": state["minutes"],
      "seconds": state["seconds"]
    });
  }

  void setMinutes(int minutes) {
    emit({
      "hours": state["hours"],
      "minutes": minutes,
      "seconds": state["seconds"]
    });
  }

  void setSeconds(int seconds) {
    emit({
      "hours": state["hours"],
      "minutes": state["minutes"],
      "seconds": seconds
    });
  }

  int getTimeInSeconds() {
    return (state["hours"]*3600) + (state["minutes"]*60) + (state["seconds"]);
  }

}