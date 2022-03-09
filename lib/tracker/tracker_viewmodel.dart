import 'dart:io';
import 'dart:math' as math;

import 'package:bonsai/bonsai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../midi/e2_data.dart';
import 'e2_data/e2_part.dart';
import 'e2_data/e2_pattern.dart';
import 'tracker_state.dart';

const partsCount = 16;
const stepsCount = 64;
const stepsPerPage = 16;
// TODO: make this config setting or set based on device screen size
const partsPerPage = 8;
const int partsPageCount = partsCount ~/ partsPerPage;

const c4MidiOnE2 = 60 + 1; //E2 midi note C4 is 61 not 60 for some reason?

enum Direction { up, down, left, right }

class TrackerViewModel extends StateNotifier<TrackerState> {
  final Stream<E2Pattern> patternStream;

  TrackerViewModel(this.patternStream)
      : super(
          const TrackerState(
            editVersion: 0,
            stepPage: 0,
            partPage: 0,
            editing: false,
          ),
        ) {
    patternStream.forEach((p) {
      state = state.copyWith(pattern: p, selectedPartIndex: 0, stepPage: 0, selectedStepIndex: 0, editVersion: 0);
    });
  }

  E2Part? get selectedPart => state.pattern?.parts[state.selectedPartIndex ?? 0];

  void nextStepPage() {
    final nuStepIndex = math.min(stepsCount - 1, (state.selectedStepIndex ?? 0) + stepsPerPage);
    state = state.copyWith(
      stepPage: state.stepPage >= 2 ? 3 : state.stepPage + 1,
      selectedStepIndex: nuStepIndex,
    );
  }

  void prevStepPage() {
    final nuStepIndex = math.max(0, state.selectedStepIndex! - stepsPerPage);
    state = state.copyWith(
      stepPage: state.stepPage <= 1 ? 0 : (state.stepPage - 1),
      selectedStepIndex: nuStepIndex,
    );
  }

  void nextStep() {
    final nuStepIndex = math.min(stepsCount - 1, state.selectedStepIndex! + 1);
    // need to make sure we move to the new page BEFORE we update the selectedStepIndex
    // as the selectedStepIndex is used relative to the page index when the UI draws it
    if (nuStepIndex == ((state.stepPage + 1) * stepsPerPage)) {
      nextStepPage();
    }
    state = state.copyWith(selectedStepIndex: nuStepIndex);
  }

  void prevStep() {
    final nuStepIndex = math.max(0, state.selectedStepIndex! - 1);
    // need to make sure we move to the new page BEFORE we update the selectedStepIndex
    // as the selectedStepIndex is used relative to the page index when the UI draws it
    if (nuStepIndex == (state.stepPage * stepsPerPage) - 1) {
      prevStepPage();
    }
    state = state.copyWith(selectedStepIndex: nuStepIndex);
  }

  void nextPart() {
    final nuPartIndex = math.min(partsCount - 1, state.selectedPartIndex! + 1);
    if (nuPartIndex == ((state.partPage + 1) * partsPerPage)) {
      nextPartPage();
    }
    state = state.copyWith(selectedPartIndex: nuPartIndex);
  }

  void prevPart() {
    final nuPartIndex = math.max(0, state.selectedPartIndex! - 1);
    if (nuPartIndex == (state.partPage * partsPerPage) - 1) {
      prevPartPage();
    }
    state = state.copyWith(selectedPartIndex: nuPartIndex);
  }

  void nextPartPage() {
    state = state.copyWith(partPage: math.min(partsPageCount - 1, state.partPage + 1));
  }

  void prevPartPage() {
    state = state.copyWith(partPage: math.max(0, state.partPage - 1));
  }

  void editing(bool val) => state = state.copyWith(editing: val);

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
  }

  void clearSelectedStepIndex() {
    state = state.copyWith(selectedStepIndex: null);
  }

  void editNote(Direction dir) {
    final stepIndex = state.selectedStepIndex;
    if (stepIndex == null) {
      log('no selected step');
      return;
    }
    final step = selectedPart?.steps[stepIndex];
    int currentNote = step?.notes[0] ?? 0;
    switch (dir) {
      case Direction.down:
        currentNote = math.max(0, currentNote - 1);
        break;
      case Direction.up:
        currentNote = math.min(127, currentNote + 1);
        break;
      case Direction.left:
        step?.stepOn = false;
        break;
      case Direction.right:
        if (currentNote == 0) {
          // if no note set, init to C-4
          currentNote = c4MidiOnE2;
        }
        step?.stepOn = true;
        break;
    }

    selectedPart?.steps[stepIndex].setNote(0, currentNote);
    state = state.copyWith(editVersion: state.editVersion + 1);
    //log('new note:$currentNote');
  }

  Future<void> stashPattern(E2Pattern pattern) async {
    final f = File('/tmp/e2pattern.dat');
    f.writeAsBytes(pattern.data);
    log('stashed pattern to:${f.path}');
  }

  Future<void> loadStash() async {
    final f = File('/tmp/e2pattern.dat');
    final data = await f.readAsBytes();

    final loadedPattern = E2Pattern(
      patternPointerFromData(data),
      data.length,
      0,
    );
    state = state.copyWith(
      pattern: loadedPattern,
      selectedPartIndex: 0,
      selectedStepIndex: 0,
      editing: false,
      partPage: 0,
      stepPage: 0,
    );
  }
}
