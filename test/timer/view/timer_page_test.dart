import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/picker/picker.dart';
import 'package:flutter_timer/timer/timer.dart';
import 'package:mocktail/mocktail.dart';

class _MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

class _MockPickerBloc extends MockBloc<PickerEvent, PickerState>
    implements PickerBloc {}

class _FakeTimerEvent extends Fake implements TimerEvent {}

extension on WidgetTester {
  Future<void> pumpTimerView(TimerBloc timerBloc, PickerBloc pickerBloc) {
    return pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: timerBloc),
            BlocProvider.value(value: pickerBloc),
          ],
          child: const TimerView(),
        ),
      ),
    );
  }
}

void main() {
  late TimerBloc timerBloc;
  late PickerBloc pickerBloc;

  setUpAll(() {
    registerFallbackValue(_FakeTimerEvent());
  });

  setUp(() {
    timerBloc = _MockTimerBloc();
    pickerBloc = _MockPickerBloc();
  });

  tearDown(() => reset(timerBloc));

  group('TimerPage', () {
    testWidgets('renders TimerView', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TimerPage()));
      expect(find.byType(TimerView), findsOneWidget);
    });
  });

  group('TimerView', () {
    testWidgets('renders initial Timer view', (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerInitial(0));
      when(() => pickerBloc.state).thenReturn(const PickerState());
      await tester.pumpTimerView(timerBloc, pickerBloc);
      expect(find.byKey(const Key('hoursInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byKey(const Key('minutesInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byKey(const Key('secondsInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('renders pause and reset button when timer is in progress',
        (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerRunInProgress(59));
      await tester.pumpTimerView(timerBloc, pickerBloc);
      expect(find.text('00:00:59'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.rectangle), findsOneWidget);
    });

    testWidgets('renders play and reset button when timer is paused',
        (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerRunPause(1200));
      await tester.pumpTimerView(timerBloc, pickerBloc);
      expect(find.text('00:20:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.rectangle), findsOneWidget);
    });

    testWidgets('renders initial Timer View when timer is finished',
        (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerRunComplete());
      when(() => pickerBloc.state).thenReturn(const PickerState());
      await tester.pumpTimerView(timerBloc, pickerBloc);
      expect(find.byKey(const Key('hoursInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byKey(const Key('minutesInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byKey(const Key('secondsInput_listwheelscrollview')),
          findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('timer started when play arrow button is pressed',
        (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerInitial(60));
      when(() => pickerBloc.state).thenReturn(const PickerState(seconds: 60));
      when(() => pickerBloc.getTimeInSeconds()).thenReturn(60);
      await tester.pumpTimerView(timerBloc, pickerBloc);
      await tester.tap(find.byIcon(Icons.play_arrow));
      verify(
        () => timerBloc.add(
          any(
            that: isA<TimerStarted>().having((e) => e.duration, 'duration', 60),
          ),
        ),
      ).called(1);
    });

    testWidgets(
        'timer pauses when pauses button is pressed '
        'while timer is in progress', (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerRunInProgress(30));
      await tester.pumpTimerView(timerBloc, pickerBloc);
      await tester.tap(find.byIcon(Icons.pause));
      verify(() => timerBloc.add(const TimerPaused())).called(1);
    });

    testWidgets(
        'timer resumes when play arrow button is pressed '
        'while timer is paused', (tester) async {
      when(() => timerBloc.state).thenReturn(const TimerRunPause(30));
      await tester.pumpTimerView(timerBloc, pickerBloc);
      await tester.tap(find.byIcon(Icons.play_arrow));
      verify(() => timerBloc.add(const TimerResumed())).called(1);
    });


    testWidgets('actions are not rebuilt when timer is running',
        (tester) async {
      final controller = StreamController<TimerState>();
      whenListen(
        timerBloc,
        controller.stream,
        initialState: const TimerRunInProgress(10),
      );
      await tester.pumpTimerView(timerBloc, pickerBloc);

      FloatingActionButton findPauseButton() {
        return tester.widget<FloatingActionButton>(
          find.byWidgetPredicate(
            (widget) =>
                widget is FloatingActionButton &&
                widget.child is Icon &&
                (widget.child! as Icon).icon == Icons.pause,
          ),
        );
      }

      final pauseButton = findPauseButton();
      controller.add(const TimerRunInProgress(9));
      await tester.pump();
      expect(pauseButton, equals(findPauseButton()));
    });
  });
}
