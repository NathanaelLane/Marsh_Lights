FloatBuffer shaderInputs = nativeFloatbuffer(simInputs.length);
int p_loc, r_loc;

final int state = 0, intermediate = 1, normals = 2, noise = 3;
int[] texLocations = new int[noise + 1];
GLWritebuffer wIntermediate, wComposite;
GLShaderProgram pPropagate, pRecalculate, pFinal;
int w = 640, h = 400;

void simSetup(){
  
  texLocations[state] = glCreateTexture(GL3.GL_RGB32F, w, h, nullBuf);
  texLocations[intermediate] = glCreateTexture(GL3.GL_RGB32F, w, h, nullBuf);
  texLocations[normals] = glCreateTexture(GL3.GL_RGB16, w, h, nullBuf);
  
  gl.bindFramebuffer(PGL.FRAMEBUFFER, fboID);
  
  GLWritebuffer clear = new GLWritebuffer(state, intermediate, normals);
  for(int i = 0; i <= normals; i++){
    gl.framebufferTexture2D(PGL.FRAMEBUFFER, attachments[i], PGL.TEXTURE_2D, texLocations[i], 0);
  }
  clear.bind();
  gl.clear(PGL.COLOR_BUFFER_BIT);
  gl.bindFramebuffer(PGL.FRAMEBUFFER, 0);
 
  wIntermediate = new GLWritebuffer(intermediate);
  wComposite = new GLWritebuffer(state, normals);
  
  pPropagate = new GLShaderProgram("propagate.fsh", "simheader.fsh", "frag_state");
  pPropagate.bindTextureLocations("state");
  
  pRecalculate = new GLShaderProgram("recalculate.fsh", "simheader.fsh", "frag_state", "frag_normal");
  pRecalculate.bindTextureLocations("state");
  
  gl.useProgram(pPropagate.pID);
  gl.uniform2f(pPropagate.getUniformLocation("step"), 1.0 / width, 1.0 / height);
  gl.useProgram(pRecalculate.pID);
  gl.uniform2f(pRecalculate.getUniformLocation("step"), 1.0 / width, 1.0 / height);
  gl.useProgram(0);
  
  p_loc = pPropagate.getUniformLocation("inputs"); 
  r_loc = pRecalculate.getUniformLocation("inputs");
  shaderInputs.clear();
  
  pFinal = new GLShaderProgram("final.fsh", null, "frag_color");
  pFinal.bindTextureLocations("normals"); 
}

void simRender(){
  gl.disable(PGL.BLEND);
  gl.bindBuffer(PGL.ARRAY_BUFFER, vboID);
 
  shaderInputs.clear();
  for(int i = 0; i < simInputs.length; i++){
    shaderInputs.put(i, lastInputs[i] + (simInputs[i] - lastInputs[i]) * 0.5);
  }
  
  gl.bindFramebuffer(PGL.FRAMEBUFFER, fboID);
  gl.viewport(0, 0, w, h);
  wIntermediate.bind();
  gl.useProgram(pPropagate.pID);
  gl.uniform1fv(p_loc, simInputs.length, shaderInputs);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[state]);
  glDrawQuad(pPropagate.gLoc);
  
  shaderInputs.clear();
  shaderInputs.put(simInputs);
  shaderInputs.flip();
  
  wComposite.bind();
  gl.useProgram(pRecalculate.pID);
  gl.uniform1fv(r_loc, simInputs.length, shaderInputs);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[intermediate]);
  glDrawQuad(pRecalculate.gLoc);

  gl.bindFramebuffer(PGL.FRAMEBUFFER, 0);
  gl.viewport(0, 0, width, height);
  gl.useProgram(pFinal.pID);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, texLocations[normals]);
  glDrawQuad(pFinal.gLoc);
  gl.activeTexture(PGL.TEXTURE0);
  gl.bindTexture(PGL.TEXTURE_2D, 0);
  gl.useProgram(0);
  gl.bindBuffer(PGL.ARRAY_BUFFER, 0);
}