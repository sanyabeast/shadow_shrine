shader_type canvas_item;

uniform sampler2D noiseTexture;
uniform vec2 direction = vec2(1, 0);
uniform float speed = 1;
uniform float min_alpha = 0;
uniform float max_alpha = 1;
uniform float alpha_curve = 2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 noiseCoord =  UV + (direction * TIME * speed);
	noiseCoord = vec2(mod(noiseCoord.x, 1), mod(noiseCoord.y, 1));
	vec4 noise = texture(noiseTexture, noiseCoord);
	COLOR.a *= mix(min_alpha, max_alpha, pow(noise.r, alpha_curve));
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
