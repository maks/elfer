import 'package:freezed_annotation/freezed_annotation.dart';

import 'e2_part.dart';
import 'e2_pattern.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({
    required int stepPage,
    E2Pattern? pattern,
    E2Part? selectedPart,
    int? selectedStepIndex,
  }) = _TrackerState;
}
