import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'midi/e2_device.dart';
import 'tracker/e2_controls_handler.dart';
import 'tracker/pattern_widget.dart';
import 'tracker/providers.dart';
import 'tracker/tracker_viewmodel.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final E2Device _e2Device;
  StreamSubscription? _e2Subscription;

  Uint8List? lastMidiMesg;
  late final TrackerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _e2Device = ref.read(e2DeviceProvider);
    _viewModel = ref.read(trackerViewModelProvider.notifier);
    _e2Subscription = subscribeE2Events(_viewModel, _e2Device, _e2Subscription);
  }

  @override
  void dispose() {
    _e2Subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(trackerViewModelProvider);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 400,
              child: Wrap(
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
                      subscribeE2Events(_viewModel, _e2Device, _e2Subscription);
                      log('subscribe to e2 events');
                    },
                  ),
                  MaterialButton(
                    child: const Text('Load'),
                    onPressed: () async {
                      await ref.read(trackerViewModelProvider.notifier).loadStash();
                      log('LOADED stashed pattern');
                    },
                  ),
                  MaterialButton(
                    child: const Text('SEND-E2'),
                    onPressed: () async {
                      final pat = viewState.pattern;
                      if (pat != null) {
                        _e2Device.sendPatternData(pat.data, pat.indexNumber);
                      } else {
                        log("cant send NO current pattern");
                      }
                    },
                  ),
                ],
              ),
            ),
            if (viewState.pattern == null) const Text('no pattern'),
            if (viewState.pattern != null)
              PatternWidget(
                pattern: viewState.pattern!,
                e2Device: _e2Device,
                editing: viewState.editing,
              ),
            StreamBuilder<String>(
              stream: _e2Device.messages,
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          snapshot.data ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
                        ),
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
