import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';

import 'e2_step.dart';

class StepView extends StatelessWidget {
  final E2Step step;
  const StepView({Key? key, required this.step}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Pitch.fromMidiNumber(step.notes[0] - 1);
    return StepContainer(text: '$p');
  }
}

class StepContainer extends StatelessWidget {
  final String text;
  final Color color;

  const StepContainer({Key? key, required this.text, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}
