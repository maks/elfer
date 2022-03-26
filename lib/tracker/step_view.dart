import 'package:flutter/material.dart';
import 'package:tonic/tonic.dart';

import '../extensions.dart';
import 'e2_data/e2_step.dart';

class StepView extends StatelessWidget {
  final E2Step step;
  final bool selected;
  final bool full;

  const StepView({Key? key, required this.step, required this.selected, required this.full}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: need to find way to display when more than 1 note, show chord names maybe?
    final String noteText = stepText(step);
    return StepContainer(text: noteText, color: fgColor, backgroundColor: bgColor);
  }

  String stepText(E2Step step) {
    final p = Pitch.fromMidiNumber(step.notes[0] - 1);
    // use normal ascii hash instead of unicode sharp to get nicer looking monofont layout
    final accidentalOrDash = p.accidentalsString.isNotEmpty ? p.accidentalsString.replaceAll('♯', '#') : ('-');
    final pitchText = '${p.letterName}$accidentalOrDash${p.octave - 1}';
    final noteText = step.notes[0] == 0 ? '---' : pitchText;
    final velocityText = step.velocity == 0 ? '--' : step.velocity.toHex();
    final gateText = step.gateTime == 0 ? '--' : (step.gateTime >= 127 ? 'TI' : step.gateTime.toHex());

    return full ? '$noteText.$velocityText.$gateText' : noteText;
  }

  Color get bgColor {
    return selected ? Colors.white24 : Colors.black;
  }

  Color get fgColor {
    return step.stepOn ? Colors.white : Colors.grey;
  }
}

class StepContainer extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;

  const StepContainer({
    Key? key,
    required this.text,
    required this.color,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyText1?.copyWith(
              color: color,
              backgroundColor: backgroundColor,
            ),
      ),
    );
  }
}
