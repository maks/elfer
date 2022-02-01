import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';

import 'pattern.dart';

class PartWidget extends StatelessWidget {
  final E2Part part;
  const PartWidget({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${part.name}:'),
          ...part.steps
              .map(
                (s) => StepWidget(step: s),
              )
              .toList()
        ],
      ),
    );
  }
}

class StepWidget extends StatelessWidget {
  final E2Step step;
  const StepWidget({Key? key, required this.step}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Pitch.fromMidiNumber(step.note1);
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
