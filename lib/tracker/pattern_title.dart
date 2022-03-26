import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'e2_data/e2_pattern.dart';
import 'providers.dart';
import 'theme.dart';

class PatternTitle extends ConsumerStatefulWidget {
  final E2Pattern pattern;

  const PatternTitle({
    Key? key,
    required this.pattern,
  }) : super(key: key);

  @override
  ConsumerState<PatternTitle> createState() => _PatternDataViewState();
}

class _PatternDataViewState extends ConsumerState<PatternTitle> {
  final _nameTextController = TextEditingController();

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameTextController.text = widget.pattern.name;
    final viewState = ref.watch(trackerViewModelProvider);
    final patternNumberFormatted = (widget.pattern.indexNumber + 1).toString().padLeft(3, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Pattern:',
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: viewState.editing ? Colors.amber : Colors.grey,
              ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            patternNumberFormatted,
            style: body1Amber(context),
          ),
        ),
        SizedBox(
          width: 200,
          height: 24,
          child: TextField(
            controller: _nameTextController,
            onChanged: (val) {
              widget.pattern.name = val;
            },
            style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.lightBlue),
          ),
        ),
      ],
    );
  }
}
