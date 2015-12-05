//#include simheader.fsh

uniform sampler2D in_z;

out vec4 frag_state;
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
	
	vec3 center = texture(in_z, frag_pos).rgb;
	vec3 samples[8];
	float f0 = ext_force();
	for(int i = 0; i < 8; i++){
		samples[i] = texture(in_z, frag_pos + step * kernel[i].xy).rgb;
		f0 += (samples[i].g - center.g) * inputs[SPRING_CONST] * kernel[i].b;
	}
	float ce = half_verlet(f0, center.rg);
	
	float fe = ext_force();
	for(int i = 0; i < 8; i++){
		fe += (samples[i].b - ce) * inputs[SPRING_CONST] * kernel[i].b;
	}
	
	//layout is F_n, F_n+1/2, Z_n-1, Z_n
	frag_state = vec4(f0, fe, center.rg);
	frag_normal = vec4(center.g, center.r, 1.0, 1.0);
}