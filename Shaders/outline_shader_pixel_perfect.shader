shader_type canvas_item;

uniform float width: hint_range(0.0, 30.0);
uniform vec4 outline_color: hint_color;
uniform vec4 unit_color: hint_color;
uniform vec4 target_color: hint_color;
uniform vec4 target_color_2: hint_color;
uniform float tolerance;

vec3 get_sprite_color_change(vec4 original_color) {
	vec3 color = original_color.rgb;
	vec3 diff = color - target_color.rgb;
	vec3 diff2 = color - target_color_2.rgb;
	float m = max(max(abs(diff.r), abs(diff.g)), abs(diff.b));
	float m2 = max(max(abs(diff2.r), abs(diff2.g)), abs(diff2.b));
	float brightness = length(color);
	color = mix(color, unit_color.rgb * brightness, step(m, tolerance));
	color = mix(color, mix(unit_color.rgb, target_color_2.rgb, 0.35) * brightness, step(m2, tolerance));
	return color;
}

void fragment() {
	vec2 size = vec2(width) / vec2(textureSize(TEXTURE, 0));
	vec4 sprite_color = texture(TEXTURE, UV);
	vec3 unit_color_change = get_sprite_color_change(sprite_color);
	float alpha = sprite_color.a;

	alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
	alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
	
	vec3 final_color = mix(outline_color.rgb, sprite_color.rgb * unit_color_change.rgb, sprite_color.a);
	COLOR = vec4(final_color.rgb, clamp(alpha, 0.0, 1.0));
}
