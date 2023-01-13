import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer/picker/picker.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:flutter_timer/timer/timer.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TimerBloc(ticker: Ticker()),
        ),
        BlocProvider(
          create: (context) => PickerBloc(),
        ),
      ],
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PickerBloc myPicker = context.read<PickerBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: BlocBuilder<TimerBloc, TimerState>(
        builder: (context, state) {
          if (state is TimerRunInProgress || state is TimerRunPause)
            return Center(child: TimerText());
          else
            return Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 50,
                    height: 220,
                    child: ListWheelScrollView.useDelegate(
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                          initialItem: myPicker.state.hours != 0
                              ? myPicker.state.hours
                              : 0),
                      onSelectedItemChanged: ((value) {
                        // add event
                        myPicker.add(PickerHoursChanged(value));
                      }),
                      itemExtent: 50,
                      overAndUnderCenterOpacity: 0.2,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24,
                        builder: (context, index) {
                          return TimePicker(num: index);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 220,
                    child: ListWheelScrollView.useDelegate(
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                          initialItem: myPicker.state.minutes != 0
                              ? myPicker.state.minutes
                              : 0),
                      onSelectedItemChanged: ((value) {
                        myPicker.add(PickerMinutesChanged(value));
                      }),
                      itemExtent: 50,
                      overAndUnderCenterOpacity: 0.2,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (context, index) {
                          return TimePicker(num: index);
                        },
                      ),
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 220,
                    child: ListWheelScrollView.useDelegate(
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                          initialItem: myPicker.state.seconds != 0
                              ? myPicker.state.seconds
                              : 0),
                      onSelectedItemChanged: ((value) {
                        myPicker.add(PickerSecondsChanged(value));
                      }),
                      itemExtent: 50,
                      overAndUnderCenterOpacity: 0.2,
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (context, index) {
                          return TimePicker(num: index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
        },
      ),
      bottomNavigationBar: Actions(),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  @override ///////
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final hoursStr = (duration / (60 * 60)).floor().toString().padLeft(2, '0');
    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$hoursStr:$minutesStr:$secondsStr',
      style: TextStyle(fontSize: 50),
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) {
        return prev.runtimeType != state.runtimeType;
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (state is TimerInitial || state is TimerRunComplete) ...[
                BlocBuilder<PickerBloc, PickerState>(
                  builder: (context, state) {
                    return FloatingActionButton(
                      backgroundColor: state.hours != 0 ||
                              state.minutes != 0 ||
                              state.seconds != 0
                          ? Colors.blue
                          : Colors.blue.shade200,
                      child: Icon(Icons.play_arrow),
                      onPressed: () {
                        if (state.hours != 0 ||
                            state.minutes != 0 ||
                            state.seconds != 0) {
                          context.read<TimerBloc>().add(TimerStarted(
                              duration: context
                                  .read<PickerBloc>()
                                  .getTimeInSeconds()));
                        }
                      },
                    );
                  },
                ),
              ],
              if (state is TimerRunInProgress) ...[
                FloatingActionButton(
                  child: Icon(Icons.pause),
                  onPressed: () => context.read<TimerBloc>().add(TimerPaused()),
                ),
                FloatingActionButton(
                  child: Icon(Icons.rectangle),
                  onPressed: () => context.read<TimerBloc>().add(TimerReset()),
                ),
              ],
              if (state is TimerRunPause) ...[
                FloatingActionButton(
                  child: Icon(Icons.play_arrow),
                  onPressed: () =>
                      context.read<TimerBloc>().add(TimerResumed()),
                ),
                FloatingActionButton(
                  child: Icon(Icons.rectangle),
                  onPressed: () => context.read<TimerBloc>().add(TimerReset()),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class TimePicker extends StatelessWidget {
  int num;

  TimePicker({required this.num});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          num < 10 ? '0' + num.toString() : num.toString(),
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
