import 'package:freezed_annotation/freezed_annotation.dart';

import 'e2_part.dart';
import 'e2_pattern.dart';
import 'e2_step.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({
    required int stepPage,
    E2Pattern? pattern,
    E2Part? selectedPart,
    E2Step? selectedStep,
  }) = _TrackerState;
}
