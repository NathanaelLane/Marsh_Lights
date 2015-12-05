//#include volheader.fsh

uniform sampler2D sim;

out vec4 frag_force;
out vec4 frag_normal;


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

void main(){

	vec4 center = texture(sim, frag_pos).rgba;
	
	vec2 force = vec2(0.0);
	for(int i = 0; i < 8; i++){
		force += (texture(sim, frag_pos + step * kernel[i].xy).xy - center.xy) * kernel[i].z * inputs[SPRING_CONST];
	}
	force -= center.xy * inputs[SPRING_CONST];
	force += ext_force();
	force += (center.zw - center.xy) * inputs[DAMPING_CONST];
	frag_force = vec4(force, 0.0, 1.0);
	frag_normal = vec4(normalize(vec3(center.xy, 0.001)) * 0.5 + 0.5, 1.0);
}