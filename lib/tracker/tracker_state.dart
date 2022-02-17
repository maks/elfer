import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracker_state.freezed.dart';

@freezed
class TrackerState with _$TrackerState {
  const factory TrackerState({required int stepPage}) = _TrackerState;
}
