import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChronoApp());
}

class ChronoApp extends StatelessWidget {
  const ChronoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chrono',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const ChronoPage(),
    );
  }
}

enum MainState { start, stop, reset }

enum PauseState { running, paused }

class ChronoPage extends StatefulWidget {
  const ChronoPage({super.key});

  @override
  State<ChronoPage> createState() => _ChronoPageState();
}

class _ChronoPageState extends State<ChronoPage> {
  StreamSubscription<int>? _tickerSub;

  int _ticks = 0;
  MainState _mainState = MainState.reset;
  PauseState _pauseState = PauseState.running;

  Stream<int> tickerStream(
      {Duration tick = const Duration(milliseconds: 100)}) async* {
    int count = 0;
    while (true) {
      await Future.delayed(tick);
      yield count++;
    }
  }

  void _start() {
    _tickerSub = tickerStream().listen((event) {
      if (_pauseState == PauseState.running) {
        setState(() {
          _ticks++;
        });
      }
    });
  }

  void _stop() {
    _tickerSub?.cancel();
  }

  void _reset() {
    setState(() {
      _ticks = 0;
    });
  }

  String _formattedTime() {
    double seconds = _ticks / 10;
    int minutes = seconds ~/ 60;
    double remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toStringAsFixed(1).padLeft(4, '0')}";
  }

  void _toggleMainState() {
    switch (_mainState) {
      case MainState.reset:
        _start();
        setState(() {
          _mainState = MainState.start;
        });
        break;

      case MainState.start:
        _stop();
        setState(() {
          _mainState = MainState.stop;
        });
        break;

      case MainState.stop:
        _reset();
        setState(() {
          _mainState = MainState.reset;
        });
        break;
    }
  }

  void _togglePauseState() {
    setState(() {
      _pauseState = _pauseState == PauseState.running
          ? PauseState.paused
          : PauseState.running;
    });
  }

  @override
  void dispose() {
    _tickerSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chrono Stopwatch'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          _formattedTime(),
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "mainButton",
              onPressed: _toggleMainState,
              backgroundColor: Colors.blueAccent,
              child: Icon(
                switch (_mainState) {
                  MainState.reset => Icons.play_arrow,
                  MainState.start => Icons.stop,
                  MainState.stop => Icons.restart_alt,
                },
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "pauseButton",
              onPressed: _togglePauseState,
              backgroundColor: _pauseState == PauseState.running
                  ? Colors.orangeAccent
                  : Colors.green,
              child: Icon(
                _pauseState == PauseState.running
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
