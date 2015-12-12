//#include simheader.fsh
 

out vec4 frag_state;


void main(){
	vec3 z = texture(state, frag_pos).rgb;
	frag_state = vec4(verlet(z), height_shift(), 1.0);
}