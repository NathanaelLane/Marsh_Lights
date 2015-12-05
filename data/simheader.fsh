#version 150

#define SPRING_CONST 0
#define DAMPING_CONST 1
#define AMPLITUDE_MULT 2
#define N_EDGE 3
#define S_EDGE 4
#define W_SOURCE 5
#define E_SOURCE 6
#define C_SOURCE 7


in vec2 frag_pos;

uniform vec2 step;
//uniform float inputs[8];
float inputs[8] = float[8](0.1, 0.006, 1.0, 0, 0, 0, 0, 0.3);

vec2 ext_force(){
	
	vec2 dir = (frag_pos * 2.0 - 1.0) * vec2(1.0, step.x / step.y);
	float dist = length(dir);
	dir /= dist;
	dist *= dist;
	return dir * ((1.0 - dist / (dist + 0.0001)) * inputs[C_SOURCE]);
}

float ext_offset(){
	
	float dist = length((frag_pos * 2.0 - 1.0) * vec2(1.0, step.x / step.y));
	dist *= dist * dist;
	return -(1 - dist / (dist + 0.00001)) * inputs[C_SOURCE];
}