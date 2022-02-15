class E2Pattern {
  final String name;
  final double tempo;
  final int swing;
  final int length;
  final int beat;
  final int key;
  final int scale;
  final int chordset;
  final int playLevel;
  final List<E2Part> parts;
  final List<int> size;

  E2Pattern({
    required this.name,
    required this.tempo,
    required this.swing,
    required this.length,
    required this.beat,
    required this.key,
    required this.scale,
    required this.chordset,
    required this.playLevel,
    required this.parts,
    required this.size,
  });

  factory E2Pattern.empty() {
    return E2Pattern(
      name: 'Pattern 1',
      tempo: 120,
      swing: 0,
      length: 16,
      beat: 0,
      key: 0,
      scale: 0,
      chordset: 0,
      playLevel: 100,
      parts: List.filled(1, E2Part.empty()),
      size: List.filled(4, 0),
    );
  }
}

class E2Part {
  final String name;
  final int lastStep;
  final int voiceAssign;
  final int oscType;
  final List<E2Step> steps;

  E2Part(
    this.name,
    this.lastStep,
    this.voiceAssign,
    this.oscType,
    this.steps,
  );

  factory E2Part.empty() {
    return E2Part('Sample', 16, 0, 0, List.filled(16, E2Step.empty()));
  }
}

class E2Step {
  final int note1;
  final int note2;
  final int note3;
  final int note4;
  final bool stepOn;
  final int velocity;
  final bool trigger;
  final int gateTime;

  E2Step({
    required this.note1,
    required this.note2,
    required this.note3,
    required this.note4,
    required this.stepOn,
    required this.velocity,
    required this.trigger,
    required this.gateTime,
  });

  factory E2Step.empty() {
    return E2Step(
      note1: 60,
      note2: 0,
      note3: 0,
      note4: 0,
      stepOn: true,
      velocity: 127,
      trigger: true,
      gateTime: 96,
    );
  }
}
