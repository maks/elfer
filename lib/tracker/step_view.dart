import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';

import 'e2_step.dart';

class StepView extends StatelessWidget {
  final E2Step step;
  const StepView({Key? key, required this.step}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Pitch.fromMidiNumber(step.notes[0] - 1);
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Text('$p'),
    );
  }
}
