import 'package:flutter/material.dart';

import 'e2_pattern.dart';
import 'part_widget.dart';
import 'pattern_data_view.dart';
import 'step_view.dart';
import 'theme.dart';

class PatternWidget extends StatelessWidget {
  final E2Pattern pattern;
  const PatternWidget({Key? key, required this.pattern}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patternNumberFormatted = (pattern.indexNumber + 1).toString().padLeft(3, '0');
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pattern:'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    patternNumberFormatted,
                    style: body1Amber(context),
                  ),
                ),
                Text(pattern.name),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            width: 600,
            child: PatternDataView(
              beat: pattern.tempo,
              swing: pattern.swing,
              scale: pattern.scale,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 34,
                  ),
                  ...List.generate(16, (i) => i)
                      .map(
                        (e) => StepContainer(
                          text: e.toRadixString(16).padLeft(2, '0').toUpperCase(),
                          color: e % 4 == 0 ? Colors.amber : Colors.white,
                        ),
                      )
                      .toList()
                ],
              ),
              ...pattern.parts
                  .map(
                    (p) => PartView(part: p),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }
}
