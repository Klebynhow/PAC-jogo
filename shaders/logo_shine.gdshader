shader_type canvas_item;

// Brilho ciano que passa pelo logo de tempos em tempos.

uniform float period = 6.0;                          // segundos entre cada passada
uniform vec3 glint = vec3(0.45, 0.95, 1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float t = fract(TIME / period) * 1.8 - 0.4;      // a faixa cruza o logo e some um tempo
	float diag = UV.x + UV.y * 0.35;
	float d = (diag - t) / 0.07;
	float band = exp(-d * d);
	c.rgb = mix(c.rgb, glint, band * 0.75 * step(0.01, c.a));
	COLOR = c;
}
