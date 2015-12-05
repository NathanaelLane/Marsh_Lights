

void settings(){

  //size(960, 600, P3D);
  fullScreen(P3D);
  PJOGL.profile = 3;
}

void setup(){
  
  midiSetup();
  
  gl = beginPGL();
  gl3 = ((PJOGL)gl).gl.getGL3();
  glSetup();
  simSetup();
  endPGL();
}

void draw(){
  gl = beginPGL();
  gl3 = ((PJOGL)gl).gl.getGL3();
  simRender();
  endPGL();
  text(frameRate, 10, 10);
}