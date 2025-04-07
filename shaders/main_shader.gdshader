shader_type spatial;

render_mode  unshaded, depth_draw_opaque, cull_disabled;
varying vec3 world_position;
varying vec3 obj_pos;
varying float local_gradient;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float value_shift = 2.0;

uniform float flash_amount : hint_range(0.0, 1.0, 0.1);


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	obj_pos = NODE_POSITION_WORLD.xyz;
	local_gradient = world_position.y - obj_pos.y;
}

void fragment() {
	vec3 color = mix(base_color.rgb / vec3(value_shift), base_color.rgb, clamp(local_gradient, 0.0, 1.0));
	vec3 mixed_color = mix(color, vec3(1.0), flash_amount);
	ALBEDO = mixed_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}