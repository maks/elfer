import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tracker_state.dart';
import 'tracker_viewmodel.dart';

final trackerViewModelProvider = StateNotifierProvider<TrackerViewModel, TrackerState>((ref) {
  return TrackerViewModel();
});
