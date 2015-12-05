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
float inputs[8] = float[8](0.05, 0.000, 1.0, 0, 0, 0, 0, 0.8);

float ext_force(){
	
	float dist = length((frag_pos * 2.0 - 1.0) * vec2(1.0, step.x / step.y));
	float rad_k = 0.0001;
	return rad_k / (rad_k + dist * dist) * inputs[C_SOURCE];
}

float int_force(in vec2 z){

	return (z.r - z.g) * inputs[DAMPING_CONST] - z.g * inputs[SPRING_CONST] * 8;
}

float half_verlet(in float f, in vec2 z0){ 
	
	float v = (z0.y - z0.x);
	return z0.y + 0.5 * v + 0.125 * (f + int_force(z0));
}