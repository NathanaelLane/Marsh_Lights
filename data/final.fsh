#version 150

in vec2 frag_pos;

uniform sampler2D normals;

out vec4 frag_color;

void main(){
	//rudimentary normalized blinn-phong ripped off the internet
	
	vec3 normal = texture(normals, frag_pos).rgb * 2.0 - 1.0;
	vec3 light = normalize(vec3(0.2, 0.5, 1.0));
	vec3 h = (light + vec3(0.0, 0.0, 1.0)) / length(light + vec3(0.0, 0.0, 1.0));
	//frag_color = vec4(vec3(pow(dot(normal, h), 1 / 2.2)), 1.0);
	
	vec3 tex = texture(normals, frag_pos).rgb;
	frag_color = vec4(tex, 1.0);
}