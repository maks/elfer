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
    final labelStyle = Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Bpm:', style: labelStyle),
        Text(
          '$beat',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        Text('Swing:', style: labelStyle),
        const SizedBox(width: 16),
        Text(
          '$swing',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        Text('Scale:', style: labelStyle),
        Text(
          scale,
          style: body1Amber(context),
        ),
      ],
    );
  }
}
