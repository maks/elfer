import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninja_hex/ninja_hex.dart';

import 'midi/e2_device.dart';
import 'tracker/e2_pattern.dart';
import 'tracker/pattern_widget.dart';
import 'tracker/providers.dart';
import 'tracker/tracker_viewmodel.dart';

void main() {
  Log.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final E2Device _e2Device;
  StreamSubscription? _e2Subscription;

  Uint8List? lastMidiMesg;

  @override
  void initState() {
    super.initState();
    _e2Device = ref.read(e2DeviceProvider);
    final vm = ref.read(trackerViewModelProvider.notifier);
    _subscribeE2Events(vm);
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
          mainAxisSize: MainAxisSize.min,
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
                    _subscribeE2Events(ref.watch(trackerViewModelProvider.notifier));
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
              stream: _e2Device.currentPatternStream,
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

  void _subscribeE2Events(TrackerViewModel viewModel) {
    if (_e2Subscription == null) {
      _e2Subscription = _e2Device.e2Events.listen((packet) {
        log('received packet: ${hexView(0, packet.data)}');
        final d = packet.data;

        // pad down in Trigger mode
        if (d[1] == 0x3C && d[2] == 0x60) {
          final int pad = d[0] & 0x0F;
          log('pad:$pad');
          viewModel.selectStepIndex(pad);
        }
      });
      log('subscribed to E2 events');
    }
  }
}
