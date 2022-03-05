import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ninja_hex/ninja_hex.dart';

import 'midi/e2_device.dart';
import 'tracker/e2_data/e2_pattern.dart';
import 'tracker/pattern_widget.dart';
import 'tracker/providers.dart';
import 'tracker/tracker_state.dart';
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
  late final TrackerViewModel _viewModel;

  // for keybd input
  final FocusNode _focusNode = FocusNode();

  E2Pattern? _currentPattern;

  @override
  void initState() {
    super.initState();
    _e2Device = ref.read(e2DeviceProvider);
    _viewModel = ref.read(trackerViewModelProvider.notifier);
    _subscribeE2Events(_viewModel);
  }

  @override
  void dispose() {
    _e2Subscription?.cancel();
    _focusNode.dispose();
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
        body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (k) {
            _handleKey(k, _viewModel, viewState);
          },
          child: Column(
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
                      _subscribeE2Events(_viewModel);
                      log('subscribe to e2 events');
                    },
                  ),
                  StreamBuilder<String>(
                    stream: _e2Device.messages,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                snapshot.data ?? '',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.orange),
                              ),
                            )
                          : Container();
                    },
                  ),
                  Text(
                    'EDIT',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: viewState.editing ? Colors.amber : Colors.grey,
                        ),
                  )
                ],
              ),
              // For debugging only:
              // MaterialButton(
              //   child: const Text('ReSync pattern'),
              //   onPressed: () async {
              //     _e2Device.getPattern();
              //   },
              // ),
              MaterialButton(
                child: const Text('SEND pattern'),
                onPressed: () async {
                  final pat = _currentPattern;
                  if (pat != null) {
                    pat.name = 'Test1a';
                    _e2Device.sendPatternData(pat.data, pat.indexNumber);
                  } else {
                    log("cant send NO current pattern");
                  }
                },
              ),
              StreamBuilder<E2Pattern>(
                stream: _e2Device.currentPatternStream,
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    _currentPattern = snapshot.data;
                    if (_currentPattern == null) {
                      return const Text('no pattern');
                    } else {
                      return PatternWidget(pattern: _currentPattern!);
                    }
                  }
                },
              ),
            ],
          ),
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
        if (d[1] == 0x3C) {
          final int pad = d[0] & 0x0F;
          final int pressDir = d[0] & 0xF0;
          log('pad:$pad');
          if (pressDir == 0x90) {
            viewModel.selectStepIndex(pad);
          } else {
            viewModel.clearSelectedStepIndex();
          }
        }
      });
      log('subscribed to E2 events');
    }
  }

  void _handleKey(RawKeyEvent event, TrackerViewModel viewModel, TrackerState viewState) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyX) {
        viewModel.editing(true);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (viewState.editing) {
          viewModel.editNote();
        } else {
          viewModel.prevStep();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (viewState.editing) {
          viewModel.editNote(down: true);
        } else {
          viewModel.nextStep();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        viewModel.prevPart();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        viewModel.nextPart();
      }
    } else if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyX) {
        viewModel.editing(false);
      }
    }
  }
}
