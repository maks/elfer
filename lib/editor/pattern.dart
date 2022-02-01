class Pattern {
  final String name;
  final double tempo;
  final int swing;
  final int length;
  final int beat;
  final int key;
  final int scale;
  final int chordset;
  final int playLevel;
  final steps = [];

  Pattern({
    required this.name,
    required this.tempo,
    required this.swing,
    required this.length,
    required this.beat,
    required this.key,
    required this.scale,
    required this.chordset,
    required this.playLevel,
  });
}

class Part {
  final int lastStep;
  final int voiceAssign;
  final int oscType;

  Part(this.lastStep, this.voiceAssign, this.oscType);
}
