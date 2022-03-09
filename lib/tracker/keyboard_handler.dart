import 'package:bonsai/bonsai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../midi/e2_device.dart';
import 'providers.dart';
import 'tracker_viewmodel.dart';

Future<bool> handleKey(
  RawKeyEvent event,
  TrackerViewModel viewModel,
  // TrackerState viewState,
  WidgetRef ref,
  // E2Pattern? pattern,
  E2Device e2Device,
) async {
  final viewState = ref.read(trackerViewModelProvider);
  final pattern = viewState.pattern;
  if (event is RawKeyDownEvent) {
    // Log.d('key', '${event.logicalKey} shift:${event.isShiftPressed}');
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      viewModel.editing(true);
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      // "w" to send pattern to E2
      final pat = pattern;
      if (pat != null) {
        e2Device.sendPatternData(pat.data, pat.indexNumber);
        Log.d('_handleKey', 'saved pat');
      } else {
        Log.d('_handleKey', 'no pattern to save');
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      // "s" to stash pattern
      final pat = pattern;
      if (pat != null) {
        viewModel.stashPattern(pat);
        Log.d('_handleKey', 'Stashed pat');
      } else {
        Log.d('_handleKey', 'no pattern to stash');
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
      // "l" to load stashed pattern
      final pat = pattern;
      if (pat != null) {
        await viewModel.loadStash();
        Log.d('_handleKey', 'Loaded stashed pat');
      } else {
        Log.d('_handleKey', 'no pattern to stash');
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (viewState.editing) {
        viewModel.editNote(Direction.up);
      } else {
        if (event.isShiftPressed) {
          //TODO: use to move around diff tracker screens?
        } else {
          viewModel.prevStep();
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (viewState.editing) {
        viewModel.editNote(Direction.down);
      } else {
        if (event.isShiftPressed) {
          //TODO: use to move around diff tracker screens?
        } else {
          viewModel.nextStep();
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (viewState.editing) {
        viewModel.editNote(Direction.left);
      } else if (event.isShiftPressed) {
        //TODO: use to move around diff tracker screens?
      } else {
        viewModel.prevPart();
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (viewState.editing) {
        viewModel.editNote(Direction.right);
      } else if (event.isShiftPressed) {
        //TODO: use to move around diff tracker screens?
      } else {
        viewModel.nextPart();
      }
    }
  } else if (event is RawKeyUpEvent) {
    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      viewModel.editing(false);
    }
  }
  return false;
}
