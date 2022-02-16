import 'package:flutter/material.dart';

import 'e2_part.dart';
import 'step_view.dart';

class PartView extends StatelessWidget {
  final E2Part part;
  const PartView({Key? key, required this.part}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${part.name}:'),
          ...part.steps
              .map(
                (s) => StepView(step: s),
              )
              .toList()
        ],
      ),
    );
  }
}
