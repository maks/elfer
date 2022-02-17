import 'package:flutter/material.dart';

import 'e2_part.dart';
import 'step_view.dart';

class PartView extends StatelessWidget {
  final E2Part part;
  final int firstStep;

  const PartView({
    Key? key,
    required this.part,
    required this.firstStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('steps: ${part.steps.length}');
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            int.parse(part.name).toRadixString(16).toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.copyWith(color: int.parse(part.name) % 2 == 0 ? Colors.amber : Colors.white),
          ),
          Text('${part.oscillator}'),
          ...part.steps
              .getRange(firstStep, firstStep + E2Part.stepsPerPage)
              .map(
                (s) => StepView(step: s),
              )
              .toList()
        ],
      ),
    );
  }
}
