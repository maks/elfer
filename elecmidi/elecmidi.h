/* 
  slighted edited version of: https://github.com/rafamj/elecmidi/blob/main/elecmidi.h
*/

struct StepType {
  unsigned char onOff;
  unsigned char gateTime;
  unsigned char velocity;
  unsigned char triggerOnOff;
  unsigned char note[4];
  unsigned char reserved[4];
};

struct PartType {
  unsigned char lastStep;
  unsigned char mute;
  unsigned char voiceAssign;
  unsigned char fill0[5];
  unsigned char oscTypel;
  unsigned char oscTypeh;
  unsigned char fill1[38];
  struct StepType step[64];
};

struct PatternType{
 unsigned char header[4];
 unsigned char size[4];
 unsigned char fill1[4];
 unsigned char fill2[4];
 unsigned char name[18];
 unsigned char tempo1;
 unsigned char tempo2;
 unsigned char swing;
 unsigned char length;
 unsigned char beat;
 unsigned char key;
 unsigned char scale;
 unsigned char chordset;
 unsigned char playlevel;
 unsigned char fill3;
 unsigned char touchScale[16];
 unsigned char masterFX[8];
 unsigned char alternate1314;
 unsigned char alternate1516;
 unsigned char fill4[8];
 unsigned char fill5[178];
 unsigned char motionSequence[1584];
 unsigned char fill6[208];
 struct PartType part[16];
 unsigned char fill7[252];
 unsigned char footer[4];
 unsigned char fill8[1024];
};