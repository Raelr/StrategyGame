shader_type canvas_item;

uniform float tiled_factor = 7.0;
uniform float aspect_ratio = 0.5;

uniform sampler2D uv_offset_texture : hint_black;
uniform vec2 uv_offset_scale = vec2(0.2,0.2);
uniform vec2 wave_size = vec2(1.0, 1.0);
uniform vec2 time_scale = vec2(1.0, 1.0);

void fragment() {
	vec2 uv_offset = UV * uv_offset_scale;
	uv_offset += TIME * time_scale;
	
	vec2 texture_based_offset = texture(uv_offset_texture, uv_offset).rg;
	texture_based_offset = texture_based_offset * 2.0 - 1.0;
	texture_based_offset *= wave_size;
	
	vec2 adjusted_uv = UV * tiled_factor;
	adjusted_uv.y *= aspect_ratio;
	
	COLOR = texture(TEXTURE, adjusted_uv + texture_based_offset);
	NORMALMAP = texture(NORMAL_TEXTURE, adjusted_uv).rgb;
}