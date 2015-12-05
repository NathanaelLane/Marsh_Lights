import com.jogamp.opengl.GL3;
import java.nio.IntBuffer;
import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.ByteOrder;

PGL gl;
GL3 gl3;

final IntBuffer buf = IntBuffer.allocate(1);
final ByteBuffer nullBuf = null;

int fboID, vboID, vshID;

final int[] attachments = {
  GL3.GL_COLOR_ATTACHMENT0,
  GL3.GL_COLOR_ATTACHMENT1,
  GL3.GL_COLOR_ATTACHMENT2,
  GL3.GL_COLOR_ATTACHMENT3,
  GL3.GL_COLOR_ATTACHMENT4,
  GL3.GL_COLOR_ATTACHMENT5,
  GL3.GL_COLOR_ATTACHMENT6,
  GL3.GL_COLOR_ATTACHMENT7,
  GL3.GL_NONE
};


void glSetup(){

  float[] vertices = {
    1f, 1f,
    -1f, 1f,
    -1f, -1f,
    -1f, -1f,
    1f, -1f,
    1f, 1f
  };
  
  FloatBuffer vboData = ByteBuffer.allocateDirect(vertices.length * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();  
  vboData.put(vertices);
  vboData.flip();
  
  buf.clear();
  gl.genBuffers(1, buf);
  vboID = buf.get(0);
  gl.bindBuffer(PGL.ARRAY_BUFFER, vboID);
  gl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * vertices.length, vboData, PGL.STATIC_DRAW);
  gl.bindBuffer(PGL.ARRAY_BUFFER, 0);
  
  vshID = glLoadShader("quad.vsh", false);
  
  gl.clearColor(0, 0, 0, 0);
  
  buf.clear();
  gl.genFramebuffers(1, buf);
  fboID = buf.get(0);
}


int glCreateTexture(int format, int w, int h, ByteBuffer data){

  buf.clear();
  gl.genTextures(1, buf);
  int texID = buf.get(0);
  gl.bindTexture(PGL.TEXTURE_2D, texID);
  gl.texImage2D(PGL.TEXTURE_2D, 0, format, w, h, 0, PGL.RGB, PGL.UNSIGNED_BYTE, data);
  gl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MIN_FILTER, PGL.NEAREST);
  gl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MAG_FILTER, PGL.LINEAR);
  gl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_S, PGL.CLAMP_TO_EDGE);
  gl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_T, PGL.CLAMP_TO_EDGE);
  gl.bindTexture(PGL.TEXTURE_2D, 0);
  return texID;
}

int glLoadShader(String filename, boolean frag) {
  return glLoadShader(filename, null, frag);
}

int glLoadShader(String filename, String header, boolean frag) {
  
  StringBuilder s = new StringBuilder();
  if(header != null){
    for(String l : loadStrings(header)){
      s.append(l).append("\n");
    }
  }
  for(String l : loadStrings(filename)) { 
    s.append(l).append("\n");
  }
  
  int id = gl.createShader(frag ? PGL.FRAGMENT_SHADER : PGL.VERTEX_SHADER);
  gl.shaderSource(id, s.toString());
  gl.compileShader(id);
  gl.getShaderiv(id, PGL.COMPILE_STATUS, (IntBuffer) buf.clear());
  if(buf.get(0) != PGL.TRUE){
    println(filename + ": shader compilation failed");
  }
  gl.getShaderiv(id, PGL.INFO_LOG_LENGTH, (IntBuffer) buf.clear());
  if(buf.get(0) > 0) println(gl.getShaderInfoLog(id));
  return id;
}


void glDrawQuad(int attribute){
  
  gl.clear(PGL.COLOR_BUFFER_BIT);
  gl.enableVertexAttribArray(attribute);
  gl.vertexAttribPointer(attribute, 2, PGL.FLOAT, false, 0, 0); 
  gl.drawArrays(PGL.TRIANGLES, 0, 6);
  gl.disableVertexAttribArray(attribute);
}


class GLShaderProgram {

  final int pID;
  final int gLoc;
  
  GLShaderProgram(String source, String header, String... outputs){
    
    int fshID = glLoadShader(source, header, true);
    pID = gl.createProgram();
    gl.attachShader(pID, vshID);
    gl.attachShader(pID, fshID);
    for(int i = 0; i < outputs.length; i++){
    
      gl3.glBindFragDataLocation(pID, i, outputs[i]);
    }
    gl.linkProgram(pID);
    buf.clear();
    gl.getProgramiv(pID, PGL.LINK_STATUS, buf);
    if(buf.get(0) != PGL.TRUE){
      println(source + ": program link failed");
    }
    //println(gl.getProgramInfoLog(pID)); //this function is currently broken in the Processing source code...
    gLoc = gl.getAttribLocation(pID, "in_position");
  }
  
  int getUniformLocation(String name){
    return gl.getUniformLocation(pID, name);
  }
  
  void bindTextureLocations(String... texNames){
    gl.useProgram(pID);
    for(int i = 0; i < texNames.length; i++){
      
      gl.uniform1i(gl.getUniformLocation(pID, texNames[i]), i);
    }
    gl.useProgram(0);
  }
}


class GLWritebuffer{
  
  final IntBuffer targets;
  
  GLWritebuffer(int... targets){
    
    this.targets = IntBuffer.allocate(targets.length);
    for(int t : targets){
      this.targets.put(attachments[t]);
    }
    this.targets.flip();
  }
  
  void bind(){
  
    gl3.glDrawBuffers(targets.limit(), targets); 
  }
}