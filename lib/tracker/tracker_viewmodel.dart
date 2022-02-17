import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_state.dart';

class TrackerViewModel extends StateNotifier<TrackerState> {
  TrackerViewModel() : super(const TrackerState(stepPage: 0));

  void nextPage() => state = state.copyWith(stepPage: state.stepPage >= 2 ? 3 : state.stepPage + 1);
  void prevPage() =>
      state = state.copyWith(stepPage: state.stepPage <= 1 ? 0 : (state.stepPage - 1));
}
