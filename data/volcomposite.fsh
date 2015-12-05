//#include volheader.fsh

uniform sampler2D now, next;

out vec4 frag_force, frag_normal;


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

	vec3 center = texture(next, frag_pos).xyz;
	
	vec3 force = vec3(0.0);
	for(int i = 0; i < 8; i++){
		//force += (texture(next, frag_pos + step * kernel[i].xy).xyz + vec3(kernel[i].xy, 0.0) - center) 
			//* kernel[i].z * inputs[SPRING_CONST];
	}
	force -= center ;//* inputs[SPRING_CONST];
	force += ext_force();
	force += (texture(now, frag_pos.xy).xyz - center) ;//* inputs[DAMPING_CONST];
	frag_force = vec4(normalize(force), 1.0);
	frag_normal = vec4(center + vec3(0.5), 1.0);
}