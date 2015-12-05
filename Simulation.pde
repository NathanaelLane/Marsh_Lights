

int state = 0, intermediate = 1, normals = 2, noise = 3;
int[] texLocations = new int[noise + 1];
GLWritebuffer wIntermediate, wComposite;
GLShaderProgram pPropagate, pRecalculate, pFinal;

boolean flip = false;
int last, next;

void simSetup(){
  
  texLocations[state] = glCreateTexture(GL3.GL_RGB32F, width, height, nullBuf);
  texLocations[intermediate] = glCreateTexture(GL3.GL_RG32F, width, height, nullBuf);
  texLocations[normals] = glCreateTexture(GL3.GL_RGB16, width, height, nullBuf);
  
  gl.bindFramebuffer(PGL.FRAMEBUFFER, fboID);
  
  GLWritebuffer clear = new GLWritebuffer(state, intermediate, normals);
  for(int i = 0; i < normals; i++){
    gl.framebufferTexture2D(PGL.FRAMEBUFFER, attachments[i], PGL.TEXTURE_2D, texLocations[i], 0);
  }
  clear.bind();
  gl.clear(PGL.COLOR_BUFFER_BIT);
  gl.bindFramebuffer(PGL.FRAMEBUFFER, 0);
 
  wIntermediate = new GLWritebuffer(intermediate);
  wComposite = new GLWritebuffer(state, normals);
  
  pPropagate = new GLShaderProgram("propagate.fsh", "simheader.fsh", "frag_sim");
  pPropagate.bindTextureLocations("old_sim", "force");
  gl.useProgram(pPropagate.pID);
  gl.uniform2f(pPropagate.getUniformLocation("step"), 1.0 / width, 1.0 / height);
  
  pRecalculate = new GLShaderProgram("recalculate.fsh", "simheader.fsh", "frag_force", "frag_normal");
  pRecalculate.bindTextureLocations("sim");
  gl.useProgram(pRecalculate.pID);
  gl.uniform2f(pRecalculate.getUniformLocation("step"), 1.0 / width, 1.0 / height);
  
  pFinal = new GLShaderProgram("final.fsh", null, "frag_color");
  pFinal.bindTextureLocations("normals"); 
}

void simRender(){
  
  gl.bindBuffer(PGL.ARRAY_BUFFER, vboID);
  
  gl.bindFramebuffer(PGL.FRAMEBUFFER, fboID);
  wIntermediate.bind();
  gl.useProgram(pPropagate.pID);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[state]);
  glDrawQuad(pPropagate.gLoc);
  
  wComposite.bind();
  gl.useProgram(pRecalculate.pID);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[intermediate]);
  glDrawQuad(pRecalculate.gLoc);

  gl.bindFramebuffer(PGL.FRAMEBUFFER, 0);
  gl.useProgram(pFinal.pID);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[normals]);
  glDrawQuad(pFinal.gLoc);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, 0);
  gl.useProgram(0);
  gl.bindBuffer(PGL.ARRAY_BUFFER, 0);
}