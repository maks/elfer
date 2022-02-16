import 'package:flutter/material.dart';

import 'e2_pattern.dart';
import 'part_widget.dart';

class PatternWidget extends StatelessWidget {
  final E2Pattern pattern;
  const PatternWidget({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Pattern: ${pattern.name}'),
        Row(children: [
          // Column(
          //   children: List.generate(16, (i) => i).map((e) => const Text('i')).toList(),
          // ),
          ...pattern.parts
              .map(
                (p) => PartView(part: p),
              )
              .toList(),
        ]),
      ],
    );
  }
}
