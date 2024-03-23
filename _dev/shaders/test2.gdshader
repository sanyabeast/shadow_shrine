// Author: @sanyabeast
// Date: Mar. 2024
// Screen space damage direction indicator shader

shader_type canvas_item;
render_mode blend_add;
uniform vec2 center_offset = vec2(0.5, 0.5);
uniform vec4 color : source_color = vec4(1., 0., 0., 0.5);

uniform float direction_n = 0;
uniform float direction_ne = 0;
uniform float direction_e = 0;
uniform float direction_se = 0;
uniform float direction_s = 0;
uniform float direction_sw = 0;
uniform float direction_w = 0;
uniform float direction_nw = 0;

uniform float MULTIPLIER = 0.56;
uniform float SCALE = 0.5;
uniform float SOFTNESS = 0.65;

float vigTypeA(vec2 dude) {
    float val = distance(vec2(dude.x, dude.y * MULTIPLIER), vec2(center_offset.x, center_offset.y * MULTIPLIER));
    val = val / SCALE;
    float vignette = smoothstep(0.2, SOFTNESS, val);
    return vignette;
}

vec4 draw_direction(vec4 inp_color, float pixelAngle, vec2 uv, float power, float direction_angle, float size) {
	if (power < 0.01) {
		return inp_color;
	}
		
    float fromAngle = radians(direction_angle - size / 2.); // Example: 45 degrees
    float toAngle = radians(direction_angle + size / 2.);   // Example: 135 degrees

    if (fromAngle < 0.0) fromAngle = 0.;
    if (toAngle < 0.0) toAngle = 0.;

    if (pixelAngle >= fromAngle && pixelAngle <= toAngle) {
		inp_color = inp_color + vec4(color.rgb, vigTypeA(uv) * power);
    }
	
	return inp_color;
}

void fragment() {
    // Calculate the angle between the current pixel and the player's position
    float pixelAngle = atan(UV.y - center_offset.y, UV.x - center_offset.x);
    // Wrap the angle into the range [0, 2*PI]
    if (pixelAngle < 0.0) pixelAngle += 2.0 * PI;
	
	vec4 out_color = vec4(0., 0., 0., 0.);
	// east
	out_color = draw_direction(out_color, pixelAngle, UV, direction_e, 360., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_e, 0., 45.);
	//
	out_color = draw_direction(out_color, pixelAngle, UV, direction_se, 45., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_s, 90., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_sw, 135., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_w, 180., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_nw, 225., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_n, 270., 45.);
	out_color = draw_direction(out_color, pixelAngle, UV, direction_ne, 315., 45.);
	
	COLOR = out_color;
}