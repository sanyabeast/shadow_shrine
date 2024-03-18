shader_type spatial;
render_mode blend_add, depth_prepass_alpha;
uniform vec4 albedo: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rimThickness:  hint_range(0.1, 2)  = 0.25;
uniform float rimBrightness:  hint_range(0, 8)  = 1.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 viewDir = normalize(-CAMERA_DIRECTION_WORLD.xyz); // Camera view direction
    float rimFactor = 1.0 - max(0.0, dot(normalize(NORMAL), VIEW)); // Calculate rim factor
	
 	rimFactor = pow(rimFactor, (1./rimThickness));
	rimFactor = clamp(rimFactor * rimBrightness, 0., 1.);
	
	EMISSION.rgb = albedo.rgb * rimFactor;
	ALPHA = rimFactor * albedo.a;
}