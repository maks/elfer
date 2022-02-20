import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';

import 'e2_step.dart';

class StepView extends StatelessWidget {
  final E2Step step;
  final Color? color;
  const StepView({
    Key? key,
    required this.step,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p = Pitch.fromMidiNumber(step.notes[0] - 1);
    // use normal ascii hash instead of unicode sharp to get nicer looking monofont layout
    final accidentalOrDash =
        p.accidentalsString.isNotEmpty ? p.accidentalsString.replaceAll('♯', '#') : ('-');
    final pitchText = '${p.letterName}$accidentalOrDash${p.octave - 1}';
    // TODO: need to find way to display when more than 1 note, show chord names maybe?
    final String noteText = step.notes[0] == 0 ? '---' : pitchText;
    return StepContainer(text: noteText, color: color ?? Colors.white);
  }
}

class StepContainer extends StatelessWidget {
  final String text;
  final Color color;

  const StepContainer({Key? key, required this.text, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }
}
