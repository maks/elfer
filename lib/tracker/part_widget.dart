import 'package:bonsai/bonsai.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_part.dart';
import 'providers.dart';
import 'step_view.dart';
import 'tracker_state.dart';

class PartView extends ConsumerWidget {
  final E2Part part;
  final int firstStep;

  const PartView({
    Key? key,
    required this.part,
    required this.firstStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(trackerViewModelProvider);
    final viewmodel = ref.watch(trackerViewModelProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(
              child: Column(
                children: [
                  Text(
                    int.parse(part.name).toRadixString(16).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: _getHeaderTextColor(_isSelected(state, part)),
                        ),
                  ),
                  Text('${part.oscillator}'),
                ],
              ),
              onPressed: () {
                log('select: ${part.name}');
                viewmodel.selectPart(part);
              }),
          ...part.steps
              .getRange(firstStep, firstStep + E2Part.stepsPerPage)
              .mapIndexed(
                (i, s) => StepView(
                  step: s,
                  color: _getStepColor(i == state.selectedStepIndex && _isSelected(state, part)),
                ),
              )
              .toList()
        ],
      ),
    );
  }

  bool _isSelected(TrackerState state, E2Part part) => state.selectedPart?.name == part.name;

  Color _getHeaderTextColor(bool isSelected) => isSelected
      ? Colors.lightBlue
      : int.parse(part.name) % 2 == 0
          ? Colors.amber
          : Colors.white;

  Color _getStepColor(bool selected) => selected ? Colors.lightBlue : Colors.white;
}
