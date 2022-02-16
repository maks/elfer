import 'package:flutter/material.dart';

import 'part_widget.dart';
import 'pattern.dart';

class PatternWidget extends StatelessWidget {
  final E2Pattern pattern;
  const PatternWidget({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Pattern: ${pattern.name}'),
      ...pattern.parts
          .map(
            (p) => PartWidget(part: p),
          )
          .toList(),
    ]);
  }
}
