shader_type canvas_item;

uniform float alpha : hint_range(0.0, 1.0) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.r = 1.;
	COLOR.b = 0.;
	COLOR.a *= alpha;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
