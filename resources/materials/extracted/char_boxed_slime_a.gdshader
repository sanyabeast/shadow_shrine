// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,depth_prepass_alpha;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform sampler2D texture_normal : hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform float normal_scale : hint_range(-16,16);
uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap,repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform sampler2D textureNoise: hint_default_black;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

varying flat vec3 norm;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	norm = NORMAL;
}


vec2 cartesianToPolar(vec2 uv) {
    float radius = length(uv);
    float angle = atan(uv.y, uv.x);
    return vec2(radius, angle);
}

void fragment() {
	
	
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	//ALPHA *= albedo.a * albedo_tex.a;
	AO = dot(texture(texture_ambient_occlusion,base_uv),ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;
	
	
	// reverse rimming
	vec3 viewDir = normalize(-CAMERA_DIRECTION_WORLD.xyz); // Camera view direction
    float rimFactor = 1.0 - max(0.0, dot(normalize(NORMAL), VIEW)); // Calculate rim factor
	
 	rimFactor = 1.-pow(1.-rimFactor, (1./0.25));
	rimFactor = clamp(rimFactor * 1., 0., 1.);
	
	EMISSION.rgb = mix(
		vec3(0., 0., 0.),
		ALBEDO.rgb / 2.,
		1.-rimFactor
	);
	
	// fake refraction
	//vec3 normx = NORMAL;
	//vec2 displacement = vec2(0.15);
	//displacement.x *= -normx.x*2.0;
	//displacement.y *= -normx.y*2.0;
	//vec4 refraction = vec4(0.0);
	//refraction = texture(screen_texture, SCREEN_UV + displacement );
	//
	//ALBEDO.rgb = mix(ALBEDO.rgb, refraction.rgb, 0.5);
	//
	
	//ALPHA = rimFactor * albedo.a;
	//float noiseValue = texture(textureNoise, base_uv).r;
	//noiseValue = ((sin(noiseValue + TIME)) + 1.) / 2.;
	//ALBEDO.rgb = mix(ALBEDO.rgb, vec3(0., 0., 0.), noiseValue);
	//
}

