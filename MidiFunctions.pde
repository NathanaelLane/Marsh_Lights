import themidibus.*;

MidiBus controller;
String midiName = "Launch Control";

final int[] knobValues = new int[16];
final int[] buttonValues = new int[8];

void midiSetup(){

  for(String s : MidiBus.availableInputs()){
    if(s.equals(midiName)){
      controller = new MidiBus(this, midiName, midiName);
      break;
    }else{
      println("Please connect Launchpad.");
      knobValues[6] = 71;
      knobValues[7] = 14;
      knobValues[14] = 20;
      knobValues[15] = 224;
      buttonValues[6] = 2;
    }
  }
}


void controllerChange(int chan, int num, int val){
  //everything should be coming in on channel 1
  int index = num & 0x7;
  switch(num >> 3 & 0x3){
    case 1: buttonValues[index] = val; break;
    case 2: knobValues[index + 8] = val; break;
    case 3: knobValues[index] = val; break;
    default: println("unknown cc"); break;
  }
}