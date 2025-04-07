shader_type spatial;

render_mode  unshaded, depth_draw_opaque;
varying vec3 world_position;
varying vec3 obj_pos;
varying float local_gradient;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float value_shift = 2.0;


uniform sampler2D pattern : hint_default_white;
uniform vec2 object_xy_size = vec2(30.0 , 22.0);
uniform float tiling = 250.0;
uniform float pattern_intensity_mult = .01;

uniform float depth_mod_mult = 1.0;


void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	obj_pos = NODE_POSITION_WORLD.xyz;
	local_gradient = (world_position.y - obj_pos.y - .5) / 6.0;
}

void fragment() {
	vec3 color = mix(base_color.rgb / vec3(value_shift), base_color.rgb, clamp(local_gradient, 0.0, 1.0));
	vec2 adjusted_uv = (UV / object_xy_size) * tiling;
	vec3 pattern_color = texture(pattern, adjusted_uv).rgb;
	pattern_color = pattern_color * pattern_intensity_mult;
	ALBEDO = (color - pattern_color) * depth_mod_mult;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}