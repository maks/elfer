import 'dart:io';
import 'dart:math' as math;

import 'package:bonsai/bonsai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app.dart';
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
            currentControl: E2Control.none,
            selectedPartOffset: 0,
            selectedStepOffset: 0,
          ),
        ) {
    patternStream.forEach((p) {
      state = state.copyWith(
        pattern: p,
        selectedPartOffset: 0,
        stepPage: 0,
        selectedStepOffset: 0,
        editVersion: 0,
      );
    });
  }

  E2Part? get selectedPart => state.pattern?.parts[partIndex];

  bool get isEditing => state.editing;

  set currentControl(E2Control c) => state = state.copyWith(currentControl: c);

  E2Control get currentControl => state.currentControl;

  int get stepIndex => state.selectedStepOffset + (state.stepPage * stepsPerPage);

  int get partIndex => state.selectedPartOffset + (state.partPage * partsPerPage);

  void nextStepPage() {
    setStepPage(state.stepPage >= 2 ? 3 : state.stepPage + 1);
  }

  void prevStepPage() {
    setStepPage(state.stepPage <= 1 ? 0 : (state.stepPage - 1));
  }

  void setStepPage(int page) {
    state = state.copyWith(
      stepPage: page,
    );
  }

  void nextStep() {
    int nuStepOffset = (state.selectedStepOffset + 1) % stepsPerPage;
    // need to make sure we move to the new page BEFORE we update the selectedStepIndex
    // as the selectedStepIndex is used relative to the page index when the UI draws it
    if (nuStepOffset == 0) {
      if (state.stepPage + 1 == (stepsCount ~/ stepsPerPage)) {
        return; //at last step of last page, do nothing
      }
      nextStepPage();
    }
    state = state.copyWith(selectedStepOffset: nuStepOffset);
  }

  void prevStep() {
    final nuStepOffset = state.selectedStepOffset - 1 < 0 ? (stepsPerPage - 1) : state.selectedStepOffset - 1;
    // need to make sure we move to the new page BEFORE we update the selectedStepIndex
    // as the selectedStepIndex is used relative to the page index when the UI draws it
    if (nuStepOffset == stepsPerPage - 1) {
      if (state.stepPage == 0) {
        return;
      }
      prevStepPage();
    }
    state = state.copyWith(selectedStepOffset: nuStepOffset);
  }

  void nextPart() {
    int nuPartOffset = (state.selectedPartOffset + 1) % partsPerPage;
    // need to make sure we move to the new page BEFORE we update the selectedStepIndex
    // as the selectedStepIndex is used relative to the page index when the UI draws it
    if (nuPartOffset == 0) {
      if (state.partPage + 1 == (partsCount ~/ partsPerPage)) {
        return; //at last step of last page, do nothing
      }
      nextPartPage();
    }
    state = state.copyWith(selectedPartOffset: nuPartOffset);
  }

  void prevPart() {
    final nuPartOffset = state.selectedPartOffset - 1 < 0 ? (partsPerPage - 1) : state.selectedPartOffset - 1;

    if (nuPartOffset == partsPerPage - 1) {
      if (state.partPage == 0) {
        return;
      }
      prevStepPage();
    }
    setPartOffset(nuPartOffset);
  }

  void setPartOffset(int p) {
    state = state.copyWith(selectedPartOffset: p);
  }

  void nextPartPage() {
    state = state.copyWith(partPage: math.min(partsPageCount - 1, state.partPage + 1));
  }

  void prevPartPage() {
    state = state.copyWith(partPage: math.max(0, state.partPage - 1));
  }

  void editing(bool val) => state = state.copyWith(editing: val);

  void selectPartOffset(int partOffset) {
    state = state.copyWith(selectedPartOffset: partOffset);
  }

  void setPartIndex(int index) {
    final nuPartOffset = index % partsPerPage;
    final nuPartPage = index ~/ partsPerPage;
    state = state.copyWith(partPage: nuPartPage);
    selectPartOffset(nuPartOffset);
  }

  void setStepIndex(int offset) {
    state = state.copyWith(selectedStepOffset: offset);
  }

  void clearSelectedStepIndex() {
    state = state.copyWith(selectedStepOffset: 0);
  }

  void editNote(Direction dir) {
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
    setNote(0, currentNote);
    //log('new note:$currentNote');
  }

  void setNote(int noteIndex, int note) {
    final step = selectedPart?.steps[stepIndex];
    final currentNote = selectedPart?.steps[stepIndex].notes[noteIndex];
    // if note currently not set, set the step to on as well
    if (currentNote == null || currentNote == 0) {
      step?.stepOn = true;
    }
    step?.setNote(noteIndex, note + 1); //again notes in Pattern data are offset by 1 from normal midi because 0=off?
    incrementEditVersion();
    log('set part[${selectedPart?.name}] step: [$stepIndex] note:$note');
  }

  void incrementEditVersion() => state = state.copyWith(editVersion: state.editVersion + 1);

  void toggleStep() {
    final step = selectedPart?.steps[stepIndex];
    step?.stepOn = !(step.stepOn);
    incrementEditVersion();
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
      selectedPartOffset: 0,
      selectedStepOffset: 0,
      editing: false,
      partPage: 0,
      stepPage: 0,
    );
  }
}
