final int 
  SPRING_CONST = 0, 
  DAMPING_CONST = 1, 
  AMPLITUDE_MULT = 2, 
  RESERVED  = 3, 
  N_EDGE = 4, 
  S_EDGE = 5, 
  W_SOURCE = 6, 
  E_SOURCE = 7, 
  C_SOURCE = 8;
  
float[] simInputs = new float[C_SOURCE + 1], lastInputs = new float[simInputs.length];

Envelope[] envelopes = new Envelope[3];
Envelope constants;

void controlSetup(){
  envelopes[0] = new Envelope(0, W_SOURCE, E_SOURCE);
  envelopes[1] = new Envelope(2, N_EDGE, S_EDGE);
  envelopes[2] = new Envelope(4, C_SOURCE, RESERVED);
  constants = new Envelope(6, 0, 0);
  simInputs[SPRING_CONST] = 0.4;
  simInputs[DAMPING_CONST] = 0.01;
  simInputs[AMPLITUDE_MULT] = 1.0;
  simInputs[C_SOURCE] = 0.0;
}


void controlUpdate(){

  for(Envelope e: envelopes){
    e.output();
  }
  simInputs[SPRING_CONST] = constants.amplitude.value * 0.0025;
  simInputs[DAMPING_CONST] = constants.cutoff.value * 0.006 + 0.001;
}

class Envelope{
  
  final int offset, lPad, rPad;
  final Knob amplitude, cutoff, deviation, center;
  
  Envelope(int offset, int lp, int rp){
    this.offset = offset;
    lPad = lp;
    rPad = rp;
    amplitude = knobs[offset];
    cutoff = knobs[offset + 1];
    deviation = knobs[offset + 8];
    center = knobs[offset + 9];
  }
  
  void output(){
    float out = amplitude(deviation.value, center.value) * amplitude.value * 3;
    if(out < cutoff.value * 0.01) out = 0;
    lastInputs[lPad] = simInputs[lPad];
    lastInputs[rPad] = simInputs[rPad];
    simInputs[lPad] = pads[offset] ? out : 0;
    simInputs[rPad] = pads[offset + 1] ? out : 0;
  }
  
  void debugDraw(int r, int g, int b){
    stroke(r, g, b);
    for(int i = 0; i < bands * 2; i++){
      point(i, height - sampledDistributions[deviation.value][abs(i/2 - center.value * 2)] * height);
    }
  }
}