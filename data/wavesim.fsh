#version 150

in vec2 frag_pos;

uniform sampler2D previous; //format is Fn, Xn, Xn-1

out vec4 frag_sim;

vec3 verlet(vec3 prev){

	//treats input as form (f(n), x(n), x(n-1)
	
	float xnew = 2 * prev.g + - prev.b + prev.r;
	float xold = prev.g;
	return vec3(xold - xnew, xnew, xold);
}

void main(){

	vec3 fxx = texture(previous, frag_pos).rgb;
	
	frag_sim = vec4(verlet(fxx), 1.0);
}

