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
    int _pendingNRPN = 0;
    if (_e2Subscription == null) {
      _e2Subscription = _e2Device.e2Events.listen((packet) {
        final d = packet.data;

        // pad down in Trigger mode
        if (d.length > 1 && d[1] == 0x3C) {
          final int pad = d[0] & 0x0F;
          final int pressDir = d[0] & 0xF0;
          log('pad:$pad');
          if (pressDir == 0x90) {
            viewModel.selectStepIndex(pad);
          } else {
            viewModel.clearSelectedStepIndex();
          }
        } else if (d.length == 3 && d[0] == 0xB0) {
          // 0xB0 - NRPN message
          // a single NRPN message can be made up of upto 4 separate CC midi messages
          // in case of Hacktribe panel control NRPNs they are max of 3: only 1 for the value
          // and upto 2 (0x62, 0x63) for the LSB, MSB of the controller "number"
          // For buttons the "NRPN value" is 0x06 CC but for encoders its 0x60 or 0x61, with the CC
          // number indicating the direction, rather than the 3rd bytes, which is always 0x01.
          //
          // set controller can be either 1 or 2 messages depe
          // ref: https://www.morningstarfx.com/post/sending-midi-nrpn-messages

          // Controllers:
          // 8192 = select, 1 = osc, 2 = filt, 3 = mod, 4 = ifx
          // 0x900 = left-arrow, 0xD00 = right-arrow, 0xC00 = Part-Left, 0x1000 = Part-Right
          // 0xB00 = shift, 0xe00 = exit
          // 0x1100 = part mute, 0x1200 = part erase, 0x1400 = trigger, 0x1600 = seq, 0x1800 = seq,
          // 0x1900 = chord, 0x1a00 = step jmp, 0x1C00 = pat set
          // 0x1100 Page1, 0x1102 = Page2, 0x1103 = Page3, 0x1104 = Page4 or 1,2,3,4 when a page already selected

          if (d[1] == 0x62) {
            _pendingNRPN = d[2];
          } else if (d[1] == 0x63) {
            // we have a MSB part of a NRPN number
            _pendingNRPN = (d[2] << 8) + _pendingNRPN;
          }

          if (d[1] == 0x06) {
            if (d[2] == 0x7F) {
              // button down
              log('NRPN: ${_pendingNRPN.toRadixString(16)}');
            } else if (d[2] == 0) {
              // button up
            }
            _pendingNRPN = 0;
          }
          if (d[2] == 0x01) {
            if (d[1] == 0x61) {
              // encoder left
            } else if (d[1] == 0x60) {
              // encoder right
            }
            log('NRPN: ${_pendingNRPN.toRadixString(16)}');
            _pendingNRPN = 0;
          }
        }
      });
      log('subscribed to E2 events');
    }
  }
}
