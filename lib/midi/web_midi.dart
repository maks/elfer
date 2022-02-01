// ignore_for_file: avoid_print, avoid_web_libraries_in_flutter

@JS()
library webmidi;

import 'package:js/js.dart';
// import 'dart:js_util' as js;

// Calls invoke JavaScript `getMidi(callback)`.
@JS('getMidi')
external void _getMidi(String deviceNamePrefix, Function callback);

MidiDispatcher? _midiControl;

// init web midi, get dispatcher for first device
Future<void> dartMidiInit() async {
  _getMidi("FL STUDIO", allowInterop((MidiDispatcher dispatcher) {
    print('got midi dispatcher from js: $dispatcher');
    _midiControl = dispatcher;
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

// send midi data to first device
void send(List<int> data) {
  _midiControl?.send(data);
}

@JS()
class MidiDispatcher {
  external MidiDispatcher(dynamic midiInput, dynamic midiOutput);
  external listenMidi(AMIDIMessageEvent mesg);
  external addInputListener(dynamic listener);
  external send(dynamic data);
}

// this is just to workaround not being able to use MIDIMessageEvent definition
// from dart:html due to bugs in dart:html Webmidi implementation
// see: https://github.com/dart-lang/sdk/issues/33248
@JS()
class AMIDIMessageEvent {}