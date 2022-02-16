import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';

import 'editor/pattern.dart';
import 'editor/pattern_widget.dart';
import 'midi/e2_device.dart';

void main() {
  Log.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MidiCommand _midiCommand = MidiCommand();
  late final E2Device _e2Device;
  StreamSubscription? _e2Subscription;

  Uint8List? lastMidiMesg;

  @override
  void initState() {
    super.initState();
    _e2Device = E2Device(_midiCommand);
    _subscribeE2Events();
  }

  @override
  void dispose() {
    _e2Subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ML-1'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                MaterialButton(
                  child: const Text('Disconnect'),
                  onPressed: () async {
                    _e2Device.disconnect();
                    log('device disconnected');
                  },
                ),
                MaterialButton(
                  child: const Text('Connect'),
                  onPressed: () async {
                    _e2Device.connectDevice();
                    _subscribeE2Events();
                    log('device connected');
                  },
                ),
              ],
            ),
            MaterialButton(
              child: const Text('Get pattern'),
              onPressed: () async {
                _e2Device.getPattern(0);
              },
            ),
            StreamBuilder<E2Pattern>(
              stream: _e2Device.currentPattern,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                } else {
                  final pattern = snapshot.data;
                  if (pattern == null) {
                    return const Text('no pattern');
                  }
                  return PatternWidget(pattern: pattern);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeE2Events() {
    _e2Subscription = _e2Device.e2Events.listen((packet) {
      log('received packet: $packet');
    });
    log('subscribed to E2 events');
  }
}
