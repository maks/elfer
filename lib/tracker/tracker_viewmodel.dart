import 'package:bonsai/bonsai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_part.dart';
import 'e2_pattern.dart';
import 'e2_step.dart';
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

  void setNote(int index, int note) {
    final step = state.selectedStep;
    if (step == null) {
      log('NO selected step to set note');
      return;
    }
    step.notes[index] = note;
    log('set step: [$index] note:$note');
  }

  void selectPart(E2Part part) {
    state = state.copyWith(selectedPart: part);
  }

  void selectStep(E2Step step) {
    state = state.copyWith(selectedStep: step);
  }
}
