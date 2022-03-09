import 'package:flutter/material.dart';

import 'theme.dart';

class PatternDataView extends StatelessWidget {
  final double beat;
  final int swing;
  final String scale;

  const PatternDataView({
    Key? key,
    required this.beat,
    required this.swing,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Bpm:'),
        Text(
          '$beat',
          style: body1Amber(context),
        ),
        const Spacer(),
        const Text('Swing:'),
        Text(
          '$swing',
          style: body1Amber(context),
        ),
        const Spacer(),
        const Text('Scale:'),
        Text(
          scale,
          style: body1Amber(context),
        ),
      ],
    );
  }
}
