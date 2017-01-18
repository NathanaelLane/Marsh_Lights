#version 150

in vec2 frag_pos;

uniform sampler2D normals;

out vec4 frag_color;

const float PI = 3.14159265;

vec3 color_wheel(in float angle){
	return vec3(sin(angle), sin(angle + 2.0 * PI / 3.0), sin(angle + 4.0 * PI / 3.0)) * 0.5 + vec3(0.5);
}

void main(){
	
	
	/* 
	rudimentary normalized blinn-phong	
	vec3 normal = texture(normals, frag_pos).rgb * 2.0 - 1.0;
	vec3 light = normalize(vec3(0.2, 0.5, 1.0));
	vec3 h = (light + vec3(0.0, 0.0, 1.0)) / length(light + vec3(0.0, 0.0, 1.0));
	frag_color = vec4(vec3(pow(dot(normal, h), 1 / 2.2)), 1.0);
	*/
	
	float theta = atan((frag_pos.y - 0.5), frag_pos.x - 0.5);
	vec3 pos = color_wheel(theta);
	vec3 qpos = color_wheel(floor(theta * 2.9999) / 3.0);
	vec3 tex = texture(normals, frag_pos).rgb;
	vec3 col = mix(qpos, pos, tex.r) * 0.85;
	col += tex.r * 0.35;
	col /= max(1, (1.0 + 2.0*max(col.r, max(col.g, col.b))) / 3.0);
	
	/*
	tex = vec3(
		mix(tex.r, 1.0, length(frag_pos) / sqrt(2)), 
		mix(tex.r, 1.0, length(vec2(1, 1) - frag_pos) / sqrt(2)), 
		mix(tex.r, 1.0, length(vec2(0.5, 0.5) - frag_pos) * 2 / sqrt(2)));
	*/
	
	// perform gamma correction on the output
	frag_color = vec4(pow(col, vec3(1 / 2.2)), 1.0);
}
