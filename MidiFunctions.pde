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
  
  // set the knobs' default values-- this code should ideally go with the Envelope logic...
  knobs[0].softValue(126);      // gain 1
  knobs[1].softValue(20);       // cutoff 1
  knobs[2].softValue(100);      // gain 2
  knobs[3].softValue(70);       // cutoff 2 
  knobs[4].softValue(112);      // gain 3
  knobs[5].softValue(70);       // cutoff 3
  knobs[6].softValue(105);      // spring constant
  knobs[7].softValue(3);        // damping constant
  knobs[8].softValue(35);       // width 1
  knobs[9].softValue(50);       // center 1
  knobs[10].softValue(3);       // width 2
  knobs[11].softValue(3);       // center 2
  knobs[12].softValue(15);      // width 3
  knobs[13].softValue(20);      // center 3
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