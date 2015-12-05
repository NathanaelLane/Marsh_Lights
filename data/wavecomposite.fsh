#version 150
#define DEPTH_CONST 0
#define DAMPING_CONST 1
#define FORCE_WEIGHT 2
#define AMPLITUDE_MULT 3
#define W_EDGE 4
#define E_EDGE 5
#define N_EDGE 6
#define S_EDGE 7
#define W_SOURCE 8
#define E_SOURCE 9

in vec2 frag_pos;

uniform sampler2D sim_output;
uniform vec2 step;
uniform float inputs[5];

out vec4 frag_sim, frag_normal;



vec3 kernel[8] = vec3[8](
	vec3(-step.x, step.y, sqrt(2)),
	vec3(0, step.y, 1),
	vec3(step.x, step.y, sqrt(2)),
	vec3(step.x, 0, 1),
	vec3(step.x, -step.y, sqrt(2)),
	vec3(0, -step.y, 1),
	vec3(-step.x, -step.y, sqrt(2)),
	vec3(-step.x, 0, 1)
);

void main(){

	// (f(n), x(n), x(n-1)
	vec3 center = texture(sim_output, frag_pos).rgb;
	center.r *= inputs[DAMPING_CONST];
	
	float force = 0;
	vec3 normal = vec3(0);
	float sample = 0;
	float sample_prev = texture(sim_output, frag_pos + kernel[0].xy).g - center.g;
	force += sample_prev * inputs[DEPTH_CONST] / kernel[0].z;
	sample_prev *= inputs[AMPLITUDE_MULT];
	for(int i = 1; i < 8; i++){
		sample = texture(sim_output, frag_pos + kernel[i].xy).g - center.g;
		force += sample * inputs[DEPTH_CONST] / kernel[i].z;
		sample *= inputs[AMPLITUDE_MULT];
		normal += cross(vec3(kernel[i].xy, sample), vec3(kernel[i - 1].xy, sample_prev));
		sample_prev = sample;
	}
	
	center.r += mix(force / 8, center.g * -inputs[DEPTH_CONST], inputs[FORCE_WEIGHT]);
	
	vec2 screen_pos = frag_pos * 2.0 - 1.0;
	float r = length(screen_pos * vec2(1.0, step.x / step.y));
	center.r += clamp((0.001 - r * r) * 1000, 0, 1) * inputs[4];
	
	frag_sim = vec4(center, 1.0);
	frag_normal = vec4(normalize(normal) * 0.5 + 0.5, 1.0);
}