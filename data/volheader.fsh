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
uniform float inputs[8];


vec3 ext_force(){

	vec2 screen_pos = frag_pos * 2.0 - 1.0;
	float r = length(screen_pos * vec2(1.0, step.x / step.y));
	r *= r;
	return vec3(0, 0, (r / (r + 0.003) - 1) * inputs[C_SOURCE]);
}