import 'dart:async';
import 'package:bonsai/bonsai.dart';
import 'package:tonic/tonic.dart';
import '../midi/e2_device.dart';
import 'tracker_viewmodel.dart';

StreamSubscription subscribeE2Events(TrackerViewModel viewModel, E2Device e2device, StreamSubscription? subscription) {
  StreamSubscription? e2Sub = subscription;
  if (e2Sub == null) {
    e2Sub = e2device.e2Events.listen((packet) {
      final d = packet.data;
      if (d.length != 3) {
        Log.d('subscribeE2Events', 'skipping large midi mesg: ${d.length}');
        return;
      }
      // pad down in Trigger mode
      if (_isChannelNote(d[0])) {
        final channel = d[0] & 0x0F;
        final note = d[1];
        final buttonDown = d[2] == 0x60;

        Log.d('subscribeE2Events', 'NOTE: ${Pitch.fromMidiNumber(note)} [down:$buttonDown] [ch:$channel]');
        viewModel.setNote(0, note); //TODO: hard code note index 0 for now
      } else if (d.length == 3 && d[0] >= 0xB0) {
        final currentChannel = d[0] - 0xB0;
        DialDir dialDir = DialDir.none;

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
            case 0x10:
              viewModel.currentControl = E2Control.partMute;
              break;
            case 0x12:
              viewModel.currentControl = E2Control.partErase;
              break;
            case 0x13:
              viewModel.currentControl = E2Control.trigger;
              break;
            case 0x15:
              viewModel.currentControl = E2Control.sequencer;
              break;
            case 0x17:
              viewModel.currentControl = E2Control.keyboard;
              break;
            case 0x18:
              viewModel.currentControl = E2Control.chord;
              break;
            case 0x19:
              viewModel.currentControl = E2Control.stepJump;
              break;
            case 0x1B:
              viewModel.currentControl = E2Control.patternSet;
              break;
            case 0x40:
              viewModel.currentControl = E2Control.selectDial;
              break;
            case 0x41:
              viewModel.currentControl = E2Control.oscDial;
              break;
            case 0x42:
              viewModel.currentControl = E2Control.filterDial;
              break;
            case 0x43:
              viewModel.currentControl = E2Control.modDial;
              break;
            case 0x44:
              viewModel.currentControl = E2Control.ifxDial;
              break;
            default:
              // just set to none for any control we are not interested in handling
              viewModel.currentControl = E2Control.none;
              break;
          }
        } else if (d[1] == 0x06) {
          if (d[2] == 0x7F) {
            _e2ButtonDown(viewModel);
          } else if (d[2] == 0) {
            _e2ButtonUp(viewModel);
          } else {
            Log.d('subscribeE2Events', 'UNrecognised button action:${d[2]}');
          }
        } else if (d[1] == 0x61) {
          dialDir = DialDir.left;
        } else if (d[1] == 0x60) {
          dialDir = DialDir.right;
        }
        viewModel.setPartIndex(currentChannel);
        Log.d('subscribeE2Events', 'ch:$currentChannel control:${viewModel.currentControl}');

        if (dialDir != DialDir.none) {
          switch (viewModel.currentControl) {
            case E2Control.selectDial:
              if (dialDir == DialDir.left) {
                viewModel.prevStep();
              } else {
                viewModel.nextStep();
              }
              break;
            default:
              // onyl care about dials
              break;
          }
        }
      }
    });
    Log.d('subscribeE2Events', 'subscribed to E2 events');
  }
  return e2Sub;
}

void _e2ButtonUp(TrackerViewModel viewModel) {}

void _e2ButtonDown(TrackerViewModel viewModel) {
  switch (viewModel.currentControl) {
    case E2Control.none:
      // NA
      break;
    case E2Control.shift:
      // NA for now
      break;
    case E2Control.exit:
      viewModel.toggleStep();
      break;
    case E2Control.leftArrow:
      viewModel.prevStep();
      break;
    case E2Control.rightArrow:
      viewModel.nextStep();
      break;
    case E2Control.b1:
      if (!viewModel.isEditing) {
        viewModel.setStepPage(0);
      }
      break;
    case E2Control.b2:
      if (!viewModel.isEditing) {
        viewModel.setStepPage(1);
      }
      break;
    case E2Control.b3:
      if (!viewModel.isEditing) {
        viewModel.setStepPage(2);
      }
      break;
    case E2Control.b4:
      if (!viewModel.isEditing) {
        viewModel.setStepPage(3);
      }
      break;
    case E2Control.prevPart:
      // NA
      break;
    case E2Control.nextPart:
      // NA
      break;
    case E2Control.partMute:
      // NA for now
      break;
    case E2Control.partErase:
      // NA for now
      break;
    case E2Control.trigger:
      viewModel.editing(false);
      break;
    case E2Control.sequencer:
      viewModel.editing(false);
      break;
    case E2Control.keyboard:
      viewModel.editing(true);
      break;
    case E2Control.chord:
      // NA for now
      break;
    case E2Control.stepJump:
      // NA for now
      break;
    case E2Control.patternSet:
      // NA for now
      break;
    case E2Control.selectDial:
      // NA for now
      break;
    case E2Control.oscDial:
      // NA for now
      break;
    case E2Control.filterDial:
      // NA for now
      break;
    case E2Control.modDial:
      // NA for now
      break;
    case E2Control.ifxDial:
      // NA for now
      break;
  }
}

bool _isChannelNote(int d) => (d >= 0x80 && d <= 0x8F) || (d >= 0x90 && d <= 0x9F);

enum DialDir { none, left, right }

enum E2Control {
  none,
  shift,
  exit,
  leftArrow,
  rightArrow,
  prevPart,
  nextPart,
  partMute,
  partErase,
  trigger,
  sequencer,
  keyboard,
  chord,
  stepJump,
  patternSet,
  b1,
  b2,
  b3,
  b4,
  selectDial,
  oscDial,
  filterDial,
  modDial,
  ifxDial,
}
