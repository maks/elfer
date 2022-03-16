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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Bpm:'),
        Text(
          '$beat',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        const Text('Swing:'),
        const SizedBox(width: 16),
        Text(
          '$swing',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        const Text('Scale:'),
        Text(
          scale,
          style: body1Amber(context),
        ),
      ],
    );
  }
}
