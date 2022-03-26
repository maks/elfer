import 'package:flutter/material.dart';

import 'e2_data/e2_pattern.dart';
import 'theme.dart';

class PatternData extends StatelessWidget {
  final E2Pattern pattern;
  const PatternData({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('BPM:', style: labelStyle),
        Text(
          '${pattern.tempo}',
          style: body1Amber(context),
        ),
        const SizedBox(height: 16),
        Text('Swing:', style: labelStyle),
        Text(
          '${pattern.swing}',
          style: body1Amber(context),
        ),
        const SizedBox(height: 16),
        Text('Scale:', style: labelStyle),
        Text(
          pattern.scale,
          style: body1Amber(context),
        ),
      ],
    );
  }
}
