import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_part.dart';
import 'e2_pattern.dart';
import 'part_widget.dart';
import 'pattern_data_view.dart';
import 'providers.dart';
import 'step_view.dart';
import 'theme.dart';
import 'tracker_state.dart';

class PatternWidget extends ConsumerWidget {
  final E2Pattern pattern;
  const PatternWidget({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(context, ref) {
    final patternNumberFormatted = (pattern.indexNumber + 1).toString().padLeft(3, '0');
    final firstStep = ref.watch(trackerViewModelProvider).stepPage * 16;
    final state = ref.watch(trackerViewModelProvider);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pattern:'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    patternNumberFormatted,
                    style: body1Amber(context),
                  ),
                ),
                Text(pattern.name),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: () => ref.read(trackerViewModelProvider.notifier).prevPage(),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: () => ref.read(trackerViewModelProvider.notifier).nextPage(),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
            width: 600,
            child: PatternDataView(
              beat: pattern.tempo,
              swing: pattern.swing,
              scale: pattern.scale,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 24,
                  ),
                  ...List.generate(E2Part.maxSteps, (i) => i)
                      .getRange(firstStep, firstStep + 16)
                      .map(
                        (idx) => StepContainer(
                          text: idx.toRadixString(16).padLeft(2, '0').toUpperCase(),
                          color: _getStepTextColor(state, idx),
                        ),
                      )
                      .toList()
                ],
              ),
              ...pattern.parts
                  .map(
                    (p) => PartView(part: p, firstStep: firstStep),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStepTextColor(TrackerState state, int stepIndex) {
    if (state.selectedStepIndex == stepIndex) {
      return Colors.lightBlue;
    }
    return stepIndex % 4 == 0 ? Colors.amber : Colors.white;
  }
}
