//#include simheader.fsh


uniform sampler2D state; 

out vec4 frag_sim;


vec2 verlet(in vec2 f, in vec2 l, in vec2 n){

	return 2 * n - l + 0.5 * f;
}


vec2 two_step_verlet(in vec2 f, in vec2 l, in vec2 n){ 
	
	vec2 v = (n - l);
	vec2 p = n + v * 0.5 + f * 0.125; 
	p = 2 * p - n + 0.125 * (
		f +
		(n - p) * inputs[SPRING_CONST] +
		ext_force() +
		(2 * (p - n) - v) * inputs[DAMPING_CONST]
	);
	
	return p;
}


void main(){

	vec2 frc = texture(force, frag_pos).rg;
	vec4 pos = texture(old_sim, frag_pos).rgba;
	frag_sim = vec4(verlet(frc, pos.ba, pos.rg), pos.rg);
}

