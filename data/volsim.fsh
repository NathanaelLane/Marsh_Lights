//#include volheader.fsh


uniform sampler2D force, last, now; 

out vec4 frag_sim;


vec3 verlet(in vec3 f, in vec3 l, in vec3 n){

	return 2 * n - l + 0.5 * f;
}


/*
 * does not account for sub-step neighbor forces, but should still be 
 * more accurate than the single-step version
 */
vec3 two_step_verlet(in vec3 f, in vec3 l, in vec3 n){ 
	
	vec3 v = (n - l);
	vec3 p = n + v * 0.5 + f * 0.125; 
	p = 2 * p - n + 0.125 * (
		f +
		(n - p) * inputs[SPRING_CONST] +
		ext_force() +
		(2 * (p - n) - v) * inputs[DAMPING_CONST]
	);
	
	return p;
}


void main(){

	frag_sim = vec4(verlet(texture(force, frag_pos).rgb, texture(last, frag_pos).rgb, texture(now, frag_pos).rgb), 1.0);
}

