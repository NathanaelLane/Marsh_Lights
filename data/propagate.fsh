//#include simheader.fsh


uniform sampler2D state; 

out vec4 frag_z;


void main(){
	//layout is F_n, F_n+1/2, Z_n-1, Z_n
	vec4 state0 = texture(state, frag_pos).rgba;
	
	//step to Z_n+1/2
	float z = half_verlet(state0.r, state0.ba);
	
	//step to Z_n+1
	z = half_verlet(state0.g + ext_force() * 0.5, vec2(2 * state0.a - z, z));
	
	float ze = half_verlet(state0.r + int_force(vec2(state0.a, z)) + ext_force(), vec2(state0.a, z));
	frag_z = vec4(state0.a, z, ze, 1.0);
}