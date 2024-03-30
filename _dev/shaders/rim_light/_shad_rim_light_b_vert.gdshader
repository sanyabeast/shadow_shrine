shader_type spatial;
render_mode blend_add, depth_prepass_alpha, cull_back, diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rimThickness:  hint_range(0.05, 4)  = 0.25;
uniform float rimBrightness:  hint_range(0, 4)  = 1.5;
uniform float emissionStrength:  hint_range(0, 1)  = 0.;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 viewDir = normalize(-CAMERA_DIRECTION_WORLD.xyz); // Camera view direction
    float rimFactor = 1.0 - max(0.0, dot(normalize(NORMAL), VIEW)); // Calculate rim factor
	
 	rimFactor = pow(rimFactor, (1./rimThickness));
	rimFactor = clamp(rimFactor * rimBrightness, 0., 1.);
	
	METALLIC = 0.;
	SPECULAR = 1.;
	ROUGHNESS = 0.1;
	ALBEDO.rgb = albedo.rgb;
	EMISSION.rgb = mix(vec3(0., 0., 0.), albedo.rgb, emissionStrength);
	ALPHA = rimFactor * albedo.a;
}