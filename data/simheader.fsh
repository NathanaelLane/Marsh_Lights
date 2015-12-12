#version 150

#define SPRING_CONST 0
#define DAMPING_CONST 1
#define AMPLITUDE_MULT 2
#define RESERVED 3
#define N_EDGE 4
#define S_EDGE 5
#define W_SOURCE 6
#define E_SOURCE 7
#define C_SOURCE 8


in vec2 frag_pos;

uniform vec2 step;
uniform sampler2D state;
uniform float inputs[9];
//float inputs[9] = float[](0.2, 0.001, 1.0, 0.57, 0, 0, 0, 0, 0.21);

vec3 kernel[8] = vec3[8](
	vec3(0, 1, 1),
	vec3(1, 1, 1 / sqrt(2)),
	vec3(1, 0, 1),
	vec3(1, -1, 1 / sqrt(2)),
	vec3(0, -1, 1),
	vec3(-1, -1, 1 / sqrt(2)),
	vec3(-1, 0, 1),
	vec3(-1, 1, 1 / sqrt(2))
);

float neighbor_force(in vec3 z){

	vec2 samples;
	float f = 0;
	for(int i = 0; i < 8; i++){
		samples = texture(state, frag_pos + step * kernel[i].xy).gb;
		f += (samples.r + samples.g - z.g - z.b) * kernel[i].b * inputs[SPRING_CONST];
	}
	return f;
}

float height_shift(){
	
	float rad = 0.00001;
	vec2 scrn_pos = (frag_pos * 2.0 - 1.0) * vec2(1.0, step.x / step.y);
	float dist = length(scrn_pos);
	dist *= dist;
	float h = rad / (rad + dist * dist) * inputs[C_SOURCE];
	dist = length(scrn_pos * vec2(1.0, 0.3) - vec2(1.0, 0.0));
	dist *= dist;
	h += rad / (rad + dist * dist) * inputs[E_SOURCE];
	dist = length(scrn_pos * vec2(1.0, 0.3) - vec2(-1.0, 0.0));
	dist *= dist;
	h += rad / (rad + dist * dist) * inputs[W_SOURCE];
	dist = length(scrn_pos * vec2(0.1, 1.0) - vec2(0.0, 0.625));
	dist *= dist;
	h += rad / (rad + dist * dist) * inputs[N_EDGE];
	dist = length(scrn_pos * vec2(0.1, 1.0) - vec2(0.0, -0.625));
	dist *= dist;
	h += rad / (rad + dist * dist) * inputs[S_EDGE];
	return h;
}

float internal_forces(in vec3 z){

	return (z.r - z.g) * inputs[DAMPING_CONST] ;//- z.g * inputs[SPRING_CONST];
}

vec2 verlet(in vec3 z){

	return vec2(z.y, z.y * 2 - z.x + 0.5 * (internal_forces(z) + neighbor_force(z)));
}
