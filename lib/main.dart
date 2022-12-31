import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';
import 'package:flutter_timer/timer/view/timer_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      home: const TimerPage(),
    );
  }
}
