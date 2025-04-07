shader_type spatial;
render_mode unshaded;

uniform float height_scale = 1.0;
uniform float speed_div = 5.0;
uniform sampler2D displacement;

varying vec2 tex_position;

uniform vec4 color : source_color = vec4(1.0);

void vertex() {
	tex_position = (VERTEX.xz / 2.0 + 0.5) * (TIME/speed_div);
	float height = texture(displacement, tex_position).x;
	VERTEX.x += height * height_scale;
}

void fragment() {
	ALBEDO = color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
