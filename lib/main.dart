import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:google_fonts/google_fonts.dart';

import 'midi/e2_device.dart';
import 'tracker/e2_pattern.dart';
import 'tracker/pattern_widget.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: Colors.white,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Elfer'),
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
            // For debugging only:
            // MaterialButton(
            //   child: const Text('ReSync pattern'),
            //   onPressed: () async {
            //     _e2Device.getPattern();
            //   },
            // ),
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
    if (_e2Subscription == null) {
      _e2Subscription = _e2Device.e2Events.listen((packet) {
        log('received packet: $packet');
      });
      log('subscribed to E2 events');
    }
  }
}
