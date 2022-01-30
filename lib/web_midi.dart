// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

@JS()
library webmidi;

import 'package:js/js.dart';
// import 'dart:js_util' as js;
// import 'dart:html';

// Calls invoke JavaScript `getMidi(callback)`.
@JS('getMidi')
external void _getMidi(Function callback);

void dartMidiInit() {
  _getMidi(allowInterop((MidiDispatcher dispatcher) {
    print('got midi dispatcher from js: $dispatcher');
    dispatcher.addInputListener(allowInterop(_rxMidi));
  }));
}

void _rxMidi(List<int> mesg) {
  // discard midi clock messages from electribe as they are sent at high rate all the time
  if (mesg[0] == 0xF8) {
    return;
  }
  print('FLUTTER midi data: $mesg');
}

@JS()
class MidiDispatcher {
  external MidiDispatcher(dynamic midiInput, dynamic midiOutput);
  external listenMidi(AMIDIMessageEvent mesg);
  external addInputListener(dynamic listener);
  external send(dynamic data);
}

@JS()
class AMIDIMessageEvent {}
