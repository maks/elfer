import 'package:flutter/material.dart';

import '../extensions.dart';
import 'e2_data/e2_pattern.dart';
import 'theme.dart';

class PatternData extends StatelessWidget {
  final E2Pattern pattern;
  const PatternData({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('BPM:', style: labelStyle),
        Text(
          '${pattern.tempo}',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        Text('Swing:', style: labelStyle),
        Text(
          '${pattern.swing.toHex()}',
          style: body1Amber(context),
        ),
        const SizedBox(width: 16),
        Text('Scale:', style: labelStyle),
        Text(
          pattern.scale,
          style: body1Amber(context),
        ),
      ],
    );
  }
}
