import 'package:e2_edit/editor/part_widget.dart';
import 'package:flutter/material.dart';

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
