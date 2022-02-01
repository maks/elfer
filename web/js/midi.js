let midiOutput;

function getMidi(deviceNamePrefix, midiReadyCallback) {
  navigator.requestMIDIAccess({ sysex: true })
    .then(function (midiAccess) {
      console.log("MIDI Access Ready, getting input, outputs...")
      const outputs = midiAccess.outputs.values();
      const inputs = midiAccess.inputs.values();

      console.log(outputs);
      for (const output of outputs) {
        console.log(output);
        if (output.name.startsWith(deviceNamePrefix)) {
          midiOutput = output;
          console.log("using MidiOut:" + output.name);
        }
      }
      console.log(inputs);
      let midiInput;
      for (const input of inputs) {
        console.log(input);
        if (input.name.startsWith(deviceNamePrefix)) {
          midiInput = input;
          console.log("using MidiOut:" + input.name);
        }
      }
      midiOutput.onstatechange = (state) => {
        console.log("state change:", state);
        //TODO: callback if connect event to midi device
        //midiStateChange((state.isTrusted && state.target instanceof  WebMidi.MIDIOutput));
      }

      if (midiInput != null) {
        let dispatcher = new MidiDispatcher(midiInput, midiOutput);
        midiReadyCallback(dispatcher);
      } else {
        console.error("== MISSING midiInput cannot create Dispatcher ==");
      }
    });
}

class MidiDispatcher {
  constructor(midiInput, midiOutput) {
    this.listeners = [];
    this.midiInput = midiInput;
    this.midiOutput = midiOutput;
    const me = this;
    midiInput.onmidimessage = function (mesg) { me.listenMidi(mesg); };
  }
  listenMidi(mesg) {
    //console.log(`Midi mesg data:`, mesg.data);
    this.listeners.forEach(listener => {
      listener(mesg.data);
    });
  }
  addInputListener(listener) {
    this.listeners.push(listener);
  }
  send(data) {
    console.log('midi send:', data)
    this.midiOutput.send(data);
  }
}
