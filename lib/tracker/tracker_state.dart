import 'package:freezed_annotation/freezed_annotation.dart';

import 'e2_controls_handler.dart';
import 'e2_data/e2_pattern.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({
    required int stepPage,
    required int partPage,
    E2Pattern? pattern,
    required int selectedPartOffset,
    required int selectedStepOffset,
    required E2Control currentControl,
    required int editVersion,
    required bool editing,
  }) = _TrackerState;
}
