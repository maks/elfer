import 'package:freezed_annotation/freezed_annotation.dart';

import 'e2_data/e2_pattern.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({
    required int stepPage,
    required int partPage,
    E2Pattern? pattern,
    int? selectedPartIndex,
    int? selectedStepIndex,
    required int editVersion,
    required bool editing,
  }) = _TrackerState;
}
