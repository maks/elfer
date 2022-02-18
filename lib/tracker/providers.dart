import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../midi/e2_device.dart';
import 'tracker_state.dart';
import 'tracker_viewmodel.dart';

final e2DeviceProvider = Provider((ref) {
  final MidiCommand _midiCommand = MidiCommand();
  return E2Device(_midiCommand);
});

final trackerViewModelProvider = StateNotifierProvider<TrackerViewModel, TrackerState>((ref) {
  final device = ref.watch(e2DeviceProvider);
  ref.onDispose(() {
    device.disconnect();
  });
  return TrackerViewModel(device.currentPatternStream);
});
