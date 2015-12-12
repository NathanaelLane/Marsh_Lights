FFT fft;
AudioIn audio;
int bands = 256;
float[] spectrum = new float[bands];
float[][] sampledDistributions = new float[128][bands];


void audioSetup(){

  fft = new FFT(this, bands);
  audio = new AudioIn(this, 0);
  audio.start();
  fft.input(audio);
  
  float ek, a, s, x;
  for(int i = 0; i < sampledDistributions.length; i++){
    s = i * 0.5 + 0.5;
    ek = -1. / (2 * s * s);
    a = 1. / (s * sqrt(TWO_PI));
    for(int j = 0; j < bands; j++){
    
      x = j;
      sampledDistributions[i][j] = a * exp(x * x * ek);
    }
  }
}

  
float amplitude(int sd, int center){

  float amp = 0;
  for(int i = 0; i < bands; i++){
    amp += spectrum[i] * sampledDistributions[sd][abs(i - center)];
  }
  return amp;
}

void audioDebugDraw(){
  strokeWeight(2);
  stroke(0);
  //background(255);
  for(int i = 0; i < bands * 2; i += 2){
    line(i, height, i, height - spectrum[i / 2] * height);
  }

}