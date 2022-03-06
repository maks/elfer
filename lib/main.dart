import 'package:bonsai/bonsai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  Log.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
