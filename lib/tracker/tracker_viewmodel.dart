import 'dart:math' as math;

import 'package:bonsai/bonsai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tonic/tonic.dart';
import 'e2_data/e2_part.dart';
import 'e2_data/e2_pattern.dart';
import 'tracker_state.dart';

class TrackerViewModel extends StateNotifier<TrackerState> {
  final Stream<E2Pattern> patternStream;

  TrackerViewModel(this.patternStream)
      : super(
          const TrackerState(
            editVersion: 0,
            stepPage: 0,
          ),
        ) {
    patternStream.forEach((p) {
      state = state.copyWith(pattern: p, selectedPartIndex: 0, stepPage: 0, selectedStepIndex: 0, editVersion: 0);
    });
  }

  E2Part? get selectedPart => state.pattern?.parts[state.selectedPartIndex ?? 0];

  void nextPage() => state = state.copyWith(stepPage: state.stepPage >= 2 ? 3 : state.stepPage + 1);
  void prevPage() => state = state.copyWith(stepPage: state.stepPage <= 1 ? 0 : (state.stepPage - 1));

  void nextStep() => state = state.copyWith(selectedStepIndex: math.min(63, state.selectedStepIndex! + 1));
  void prevStep() => state = state.copyWith(selectedStepIndex: math.max(0, state.selectedStepIndex! - 1));

  void nextPart() => state = state.copyWith(selectedPartIndex: math.min(15, state.selectedPartIndex! + 1));
  void prevPart() => state = state.copyWith(selectedPartIndex: math.max(0, state.selectedPartIndex! - 1));

  void setNote(int index, int note) {
    final stepIndex = state.selectedStepIndex;
    if (stepIndex == null) {
      log('NO selected step to set note');
      return;
    }
    final step = selectedPart?.steps[stepIndex];
    if (step == null) {
      log('NO selected Part to set note');
      return;
    }
    step.notes[index] = note;
    log('set step: [$index] note:$note');
  }

  void selectPartIndex(int partIndex) {
    state = state.copyWith(selectedPartIndex: partIndex);
  }

  void selectStepIndex(int index) {
    state = state.copyWith(selectedStepIndex: index);
    log('sel step: ${Pitch.fromMidiNumber((selectedPart?.steps[index].notes[0] ?? 0) - 1)}');
  }

  void clearSelectedStepIndex() {
    state = state.copyWith(selectedStepIndex: null);
  }

  void editNote({bool? down}) {
    final stepIndex = state.selectedStepIndex;
    if (stepIndex == null) {
      log('no selected step');
      return;
    }
    int currentNote = selectedPart?.steps[stepIndex].notes[0] ?? 0;
    if (true == down) {
      currentNote = math.max(0, currentNote - 1);
    } else {
      currentNote = math.min(127, currentNote + 1);
    }
    selectedPart?.steps[stepIndex].setNote(0, currentNote);
    state = state.copyWith(editVersion: state.editVersion + 1);
    log('new note:$currentNote');
  }
}
