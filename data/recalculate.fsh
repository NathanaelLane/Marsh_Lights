//#include simheader.fsh


out vec4 frag_state;
out vec4 frag_normal;


void main(){
	
	vec3 z = texture(state, frag_pos).rgb;
	
	frag_state = vec4(verlet(z), height_shift(), 1.0);
	
	frag_normal = vec4(vec3(1.0, 0.8, 0.5) * (z.g + z.b + 0.5), 1.0);
}