import 'package:bonsai/bonsai.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../midi/e2_device.dart';
import 'e2_data/e2_part.dart';
import 'e2_data/e2_pattern.dart';
import 'keyboard_handler.dart';
import 'part_widget.dart';
import 'pattern_data_view.dart';
import 'providers.dart';
import 'step_view.dart';
import 'theme.dart';
import 'tracker_state.dart';
import 'tracker_viewmodel.dart';

class PatternWidget extends ConsumerStatefulWidget {
  final E2Pattern pattern;
  final E2Device e2Device;
  final bool editing;

  const PatternWidget({
    Key? key,
    required this.pattern,
    required this.e2Device,
    required this.editing,
  }) : super(key: key);

  @override
  ConsumerState<PatternWidget> createState() => _PatternWidgetState();
}

class _PatternWidgetState extends ConsumerState<PatternWidget> {
  final _nameTextController = TextEditingController();

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
    _nameTextController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final patternNumberFormatted = (widget.pattern.indexNumber + 1).toString().padLeft(3, '0');
    final firstStep = ref.watch(trackerViewModelProvider).stepPage * stepsPerPage;
    final state = ref.watch(trackerViewModelProvider);

    final partStartIndex = state.partPage * partsPerPage;
    final partEndIndex = (state.partPage + 1) * partsPerPage;

    _nameTextController.text = widget.pattern.name;

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pattern:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: widget.editing ? Colors.amber : Colors.grey,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      patternNumberFormatted,
                      style: body1Amber(context),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _nameTextController,
                      onChanged: (val) {
                        widget.pattern.name = val;
                      },
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.lightBlue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8),
              child: PatternDataView(
                beat: widget.pattern.tempo,
                swing: widget.pattern.swing,
                scale: widget.pattern.scale,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // step number label column
                Column(
                  children: [
                    Container(
                      height: 28,
                    ),
                    ...List.generate(E2Part.maxSteps, (i) => i)
                        .getRange(firstStep, firstStep + 16)
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
                        partOffset: index % partsPerPage,
                      ),
                    )
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStepTextColor(TrackerState state, int stepIndex) {
    if (state.selectedStepOffset == stepIndex) {
      return Colors.lightBlue;
    }
    return stepIndex % 4 == 0 ? Colors.amber : Colors.white;
  }
}
