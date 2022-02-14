# e2_edit

A pattern editor for korg electribe 2's.

## Getting Started

Initially runs only on web. Will add android/linux support shortly.

Run in non-Chrome browser, ie. Firefox using: `flutter run -d web-server`

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