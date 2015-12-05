#version 150 

in vec2 in_position;

out vec2 frag_pos;

void main() {

	gl_Position = vec4(in_position, 1.0, 1.0);
	
	frag_pos = (in_position * 0.5 + 0.5);
}
