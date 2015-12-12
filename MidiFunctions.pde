import themidibus.*;

MidiBus controller;
String midiName = "Launch Control";

final Knob[] knobs = new Knob[16];
final boolean[] pads = new boolean[8];

void midiSetup(){

  for(String s : MidiBus.availableInputs()){
    if(s.equals(midiName)){
      controller = new MidiBus(this, midiName, midiName);
      break;
    }else{
      println("Please connect Launchpad.");
    }
  }
  
  for(int i = 0; i < knobs.length; i++){
    knobs[i] = new Knob();
    //knobs[i].softValue(int(random(1.0) * 127)); 
  }
  for(int i = 0; i < pads.length; i++){
    pads[i] = true;
  }
}


void controllerChange(int chan, int num, int val){
  //everything should be coming in on channel 1
  int index = num & 0x7;
  switch(num >> 3 & 0x3){
    case 1: pads[index] = !pads[index]; break;
    case 2: knobs[index + 8].hardValue(val); break;
    case 3: knobs[index].hardValue(val); break;
    default: println("unknown cc"); break;
  }
}

class Knob{
  
  boolean restored = true;
  int value;
  
  void softValue(int val){
    value = val;
    //restored = false;
  }
  
  void hardValue(int val){
    if(!restored){
      if(val == value){
        restored = true;
      }else{
        return;
      }
    }
    value = val;
  }
}