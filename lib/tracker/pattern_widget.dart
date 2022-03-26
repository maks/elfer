import 'package:bonsai/bonsai.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../midi/e2_device.dart';
import 'e2_data/e2_part.dart';
import 'e2_data/e2_pattern.dart';
import 'keyboard_handler.dart';
import 'part_widget.dart';
import 'pattern_data_widget.dart';
import 'pattern_title.dart';
import 'providers.dart';
import 'step_view.dart';
import 'tracker_state.dart';
import 'tracker_viewmodel.dart';

class PatternWidget extends ConsumerStatefulWidget {
  final E2Pattern pattern;
  final E2Device e2Device;

  const PatternWidget({
    Key? key,
    required this.pattern,
    required this.e2Device,
  }) : super(key: key);

  @override
  ConsumerState<PatternWidget> createState() => _PatternWidgetState();
}

class _PatternWidgetState extends ConsumerState<PatternWidget> {
  // for keybd input
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    final viewModel = ref.read(trackerViewModelProvider.notifier);

    super.initState();
    _focusNode.onKey = (node, event) {
      handleKey(
        event,
        viewModel,
        ref,
        widget.e2Device,
      ).then((value) {
        if (value) {
          log('next focus');
          return _focusNode.nextFocus();
        }
      });
      _focusNode.requestFocus();
      return KeyEventResult.handled;
    };
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final viewModel = ref.watch(trackerViewModelProvider.notifier);
    final state = ref.watch(trackerViewModelProvider);
    final firstStep = state.stepPage * stepsPerPage;

    final partStartIndex = state.partPage * viewModel.partsPerPage;
    final partEndIndex = (state.partPage + 1) * viewModel.partsPerPage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 32),
          child: PatternTitle(
            pattern: widget.pattern,
          ),
        ),
        KeyboardListener(
          autofocus: true,
          focusNode: _focusNode,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // step number label column
              Column(
                children: [
                  // the sizedbox and 2 text offset to match each part header
                  const SizedBox(height: 2),
                  Text(' ', style: Theme.of(context).textTheme.bodyText1),
                  Text(' ', style: Theme.of(context).textTheme.bodyText1),
                  ...List.generate(E2Part.maxSteps, (i) => i)
                      .getRange(firstStep, firstStep + stepsPerPage)
                      .map(
                        (idx) => StepContainer(
                          text: idx.toRadixString(16).padLeft(2, '0').toUpperCase(),
                          color: _getStepTextColor(state, idx),
                          backgroundColor: Colors.black, //TODO: set based on selection state
                        ),
                      )
                      .toList()
                ],
              ),
              ...widget.pattern.parts
                  .getRange(partStartIndex, partEndIndex)
                  .mapIndexed(
                    (index, p) => PartView(
                      part: p,
                      firstStep: firstStep,
                      partOffset: index % viewModel.partsPerPage,
                    ),
                  )
                  .toList(),
              const SizedBox(width: 16),
              PatternData(pattern: widget.pattern),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStepTextColor(TrackerState state, int stepIndex) {
    if (state.selectedStepOffset == stepIndex) {
      return Colors.lightBlue;
    }
    return stepIndex % 4 == 0 ? Colors.amber : Colors.white;
  }
}
