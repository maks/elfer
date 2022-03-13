import 'dart:async';
import 'dart:typed_data';

import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'midi/e2_device.dart';
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
    _subscribeE2Events(_viewModel);
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
                MaterialButton(
                  child: const Text('Load'),
                  onPressed: () async {
                    await ref.read(trackerViewModelProvider.notifier).loadStash();
                    log('LOADED stashed pattern');
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
              ],
            ),
            MaterialButton(
              child: const Text('SEND pattern'),
              onPressed: () async {
                final pat = viewState.pattern;
                if (pat != null) {
                  _e2Device.sendPatternData(pat.data, pat.indexNumber);
                } else {
                  log("cant send NO current pattern");
                }
              },
            ),
            if (viewState.pattern == null) const Text('no pattern'),
            if (viewState.pattern != null)
              PatternWidget(
                pattern: viewState.pattern!,
                e2Device: _e2Device,
              ),
            Text(
              'EDIT',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: viewState.editing ? Colors.amber : Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeE2Events(TrackerViewModel viewModel) {
    if (_e2Subscription == null) {
      _e2Subscription = _e2Device.e2Events.listen((packet) {
        final d = packet.data;
        if (d.length != 3) {
          log('skipping large midi mesg: ${d.length}');
          return;
        }
        // pad down in Trigger mode
        if (d.length > 1 && d[1] == 0x3C) {
          final int pad = d[0] & 0x0F;
          final int pressDir = d[0] & 0xF0;

          if (pressDir == 0x90) {
            log('PAD down in trigger mode?');
          }
        } else if (d.length == 3 && d[0] >= 0xB0) {
          final currentChannel = d[0] - 0xB0;
          if (d[1] == 0x62) {
            switch (d[2]) {
              case 0x0A:
                viewModel.currentControl = E2Control.shift;
                break;
              case 0x0D:
                viewModel.currentControl = E2Control.exit;
                break;
              case 0x08:
                viewModel.currentControl = E2Control.leftArrow;
                break;
              case 0x0C:
                viewModel.currentControl = E2Control.rightArrow;
                break;
              case 0x3C:
                viewModel.currentControl = E2Control.b1;
                break;
              case 0x3D:
                viewModel.currentControl = E2Control.b2;
                break;
              case 0x3E:
                viewModel.currentControl = E2Control.b3;
                break;
              case 0x3F:
                viewModel.currentControl = E2Control.b4;
                break;
              case 0x0B:
                viewModel.currentControl = E2Control.prevPart;
                break;
              case 0x0F:
                viewModel.currentControl = E2Control.nextPart;
                break;
              default:
                // jsut set to none for any control we are not interested in handling
                viewModel.currentControl = E2Control.none;
                break;
            }
          } else if (d[1] == 0x06) {
            if (d[2] == 0x7F) {
              _e2ButtonDown(viewModel);
            } else if (d[2] == 0) {
              _e2ButtonUp(viewModel);
            } else {
              log('UNrecognised button action:${d[2]}');
            }
          }
          viewModel.setPartIndex(currentChannel);
          log('ch:$currentChannel control:${viewModel.currentControl}');
        }
      });
      log('subscribed to E2 events');
    }
  }

  void _e2ButtonUp(TrackerViewModel viewModel) {}

  void _e2ButtonDown(TrackerViewModel viewModel) {
    switch (viewModel.currentControl) {
      case E2Control.none:
        // TODO: Handle this case.
        break;
      case E2Control.shift:
        // TODO: Handle this case.
        break;
      case E2Control.exit:
        // TODO: Handle this case.
        break;
      case E2Control.leftArrow:
        viewModel.prevStep();
        break;
      case E2Control.rightArrow:
        viewModel.nextStep();
        break;
      case E2Control.b1:
        viewModel.setStepPage(0);
        break;
      case E2Control.b2:
        viewModel.setStepPage(1);
        break;
      case E2Control.b3:
        viewModel.setStepPage(2);
        break;
      case E2Control.b4:
        viewModel.setStepPage(3);
        break;
      case E2Control.prevPart:
        // NA
        break;
      case E2Control.nextPart:
        // NA
        break;
    }
  }
}

enum E2Control {
  none,
  shift,
  exit,
  leftArrow,
  rightArrow,
  prevPart,
  nextPart,
  b1,
  b2,
  b3,
  b4,
}
