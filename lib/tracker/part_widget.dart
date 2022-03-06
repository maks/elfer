import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_data/e2_part.dart';
import 'providers.dart';
import 'step_view.dart';
import 'tracker_state.dart';

class PartView extends ConsumerWidget {
  final E2Part part;
  final int firstStep;
  final int partIndex;

  const PartView({
    Key? key,
    required this.part,
    required this.firstStep,
    required this.partIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(trackerViewModelProvider);
    final relativeStepIndex =
        state.stepPage != 0 ? state.selectedStepIndex! % (16 * state.stepPage) : state.selectedStepIndex;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              // Part name header
              Text(
                int.parse(part.name).toRadixString(16).toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: _getHeaderTextColor(_isSelected(state, partIndex)),
                    ),
              ),
              Text('${part.oscillator}'),
            ],
          ),
          ...part.steps
              .getRange(firstStep, firstStep + E2Part.stepsPerPage)
              .mapIndexed(
                (i, s) => StepView(
                  step: s,
                  color: _getStepColor((i == relativeStepIndex) && _isSelected(state, partIndex)),
                ),
              )
              .toList()
        ],
      ),
    );
  }

  bool _isSelected(TrackerState state, int partIndex) => state.selectedPartIndex == partIndex;

  Color _getHeaderTextColor(bool isSelected) => isSelected
      ? Colors.lightBlue
      : partIndex % 2 == 0
          ? Colors.amber
          : Colors.white;

  Color _getStepColor(bool selected) => selected ? Colors.lightBlue : Colors.white;
}
