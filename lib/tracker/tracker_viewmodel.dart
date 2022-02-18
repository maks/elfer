import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_pattern.dart';
import 'tracker_state.dart';

class TrackerViewModel extends StateNotifier<TrackerState> {
  final Stream<E2Pattern> patternStream;

  TrackerViewModel(this.patternStream) : super(const TrackerState(stepPage: 0)) {
    patternStream.forEach((p) {
      _pattern = p;
    });
  }

  set _pattern(E2Pattern p) => state = state.copyWith(pattern: p);

  void nextPage() => state = state.copyWith(stepPage: state.stepPage >= 2 ? 3 : state.stepPage + 1);
  void prevPage() =>
      state = state.copyWith(stepPage: state.stepPage <= 1 ? 0 : (state.stepPage - 1));

  void setNote(int part, int index, int note) {}
}
