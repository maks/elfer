import 'package:freezed_annotation/freezed_annotation.dart';

import 'e2_pattern.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({E2Pattern? pattern, required int stepPage}) = _TrackerState;
}
