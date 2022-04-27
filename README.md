# elfer

A pattern editor, in the "style" of a Tracker, for the Korg Electribe 2's (synth, sampler, hacktribe).

## Status

This is very much a WORK-IN-PROGRESS, not too much works right now, except for reading a pattern in from the E2.

[![youtube demo video](https://yt-embed.herokuapp.com/embed?v=-vGEu_1CHNk)](https://www.youtube.com/watch?v=-vGEu_1CHNk "demo of work-in-progress of Elfer")

### Features

* [x] Display partial pattern in tracker UI
* [x] Switch patterns in tracker UI using E2 dial
* [x] Display full pattern (all 64 steps) 
* [x] Edit pattern notes in tracker UI using keyboard
* [x] Edit pattern notes in tracker UI using E2 controls (Hacktribe only)
* [x] Send edited pattern back to E2
* [x] Stash/Load current pattern with app
* [x] display step on/off, velocity & gate in tracker UI
* [ ] Edit step on-off, velocity & gate in tracker UI
* [ ] Send pattern to E2 current pattern, not save to pattern slot on E2
* [ ] Edit pattern parts, osc, ifx etc in Tracker UI
* [ ] Edit instrument patchs (samples?) in Tracker UI
* [ ] Playback pattern(s) from Tracker state (without sending to E2)
* more?

## Getting Started

I'm currently developing with Flutter beta channel.

Currently only works on Linux. 

Android support coming soon.


## Debugging

### Linux

To check midi incoming via cli.

To  list ports:
```
> aseqdump -l # will list ports
Port    Client name                      Port name
  0:0    System                           Timer
  0:1    System                           Announce
 14:0    Midi Through                     Midi Through Port-0
 32:0    electribe2 sampler               electribe2 sampler electribe2 s
```

To see incoming messages (using above port number):
```
aseqdump -p 32:0
```

Audio output on oscilloscope:
```
padsp xoscope
```