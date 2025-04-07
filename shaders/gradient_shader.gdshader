shader_type spatial;

render_mode  unshaded, depth_draw_opaque;
varying vec3 world_position;
varying vec3 obj_pos;
varying float local_gradient;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float value_shift = 2.0;

uniform float outline_width : hint_range(0.0, 20.0, 0.1) = 2.0;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}



void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	obj_pos = NODE_POSITION_WORLD.xyz;
	local_gradient = world_position.y - obj_pos.y;
}

void fragment() {
	vec3 color = mix(base_color.rgb / vec3(value_shift), base_color.rgb, clamp(local_gradient, 0.0, 1.0));
	float basic_fresnel = fresnel(outline_width, NORMAL, VIEW);
	//pick
	float smooth_fresnel = smoothstep(.01, .5, basic_fresnel);
	float hard_fresnel = step(.25, basic_fresnel);

	//ALBEDO = mix(color, color / vec3(value_shift), hard_fresnel);
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}