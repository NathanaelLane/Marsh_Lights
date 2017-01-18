import processing.sound.*;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.ByteOrder;

void settings(){

  //size(640, 400, P3D);
  fullScreen(P3D, 1);
  PJOGL.profile = 3;
}

void setup(){
  
  midiSetup();
  audioSetup();
  controlSetup();
  gl = beginPGL();
  gl3 = ((PJOGL)gl).gl.getGL3();
  glSetup();
  simSetup();
  endPGL();
}

void draw(){
  fft.analyze(spectrum);
  controlUpdate();
  gl = beginPGL();
  gl3 = ((PJOGL)gl).gl.getGL3();
  simRender();
  endPGL();
  audioDebugDraw();
  envelopes[0].debugDraw(255, 30, 0);
  envelopes[1].debugDraw(10, 255, 30);
  envelopes[2].debugDraw(0, 30, 255);
  text(frameRate, 10, 10);
  //simInputs[C_SOURCE] = 0.;
}

FloatBuffer nativeFloatbuffer(int len){

  return ByteBuffer.allocateDirect(len * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
}