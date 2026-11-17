shader_type canvas_item;

// Animacao do primeiro plano do menu (arte 256x144):
//  - fita ciano do topo ondula e recebe um pulso de luz que viaja por ela
//  - chamas/faiscas ciano tremeluzem
//  - aura roxa escura do livro "respira"
//  - brilho passa pelo cabelo da Vanessa
// So troca cores/pixels da propria arte, nada precisa de arte nova.

uniform float ribbon_wave = 1.0;     // amplitude da onda da fita (em pixels)
uniform float shimmer = 0.09;        // tremulo das chamas
uniform float aura_pulse = 0.55;     // pulsar da aura roxa
uniform float hair_shine = 0.4;      // brilho no cabelo

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec4 texel(vec2 p) {
	return texture(TEXTURE, (floor(p) + 0.5) * TEXTURE_PIXEL_SIZE);
}

bool is_cyan(vec4 c) {
	vec3 h = rgb2hsv(c.rgb);
	return c.a > 0.5 && h.x > 0.44 && h.x < 0.56 && h.y > 0.4 && h.z > 0.6;
}

void fragment() {
	vec2 p = floor(UV / TEXTURE_PIXEL_SIZE);   // pixel atual (0..255, 0..143)
	vec4 c = texel(p);

	bool in_ribbon_area = p.y < 39.0;

	// --- fita ciano: onda vertical (so no topo, onde o fundo e liso)
	if (in_ribbon_area) {
		float dy = floor(sin(p.x * 0.22 - TIME * 2.6) * ribbon_wave + 0.5);
		vec4 s = texel(p + vec2(0.0, -dy));
		if (is_cyan(s)) {
			c = s;
		} else if (is_cyan(c)) {
			c = vec4(0.0);
		}
	}

	if (is_cyan(c)) {
		// tremulo em blocos de 4 px, ~2 vezes por segundo
		float n = hash(floor(p / 4.0) + floor(TIME * 2.0));
		float amount = in_ribbon_area ? shimmer * 0.4 : shimmer;
		c.rgb *= 1.0 + amount * (n - 0.5) * 2.0;

		// pulso de luz viajando pela fita
		if (in_ribbon_area) {
			float pulse_x = mod(TIME * 50.0, 340.0) - 40.0;
			float d = (p.x - pulse_x) / 12.0;
			c.rgb = mix(c.rgb, vec3(1.0), exp(-d * d) * 0.85);
		}
	} else if (c.a > 0.5) {
		vec3 h = rgb2hsv(c.rgb);
		bool purple = h.x > 0.7 && h.x < 0.85;
		if (purple && h.z < 0.45) {
			// aura escura do livro respirando
			c.rgb *= 1.0 + aura_pulse * (0.5 + 0.5 * sin(TIME * 1.8));
		} else if (purple && p.x > 150.0) {
			// brilho diagonal passando pelo cabelo
			float t = fract(TIME * 0.18);
			float diag = (p.x + p.y * 0.6) / 342.0;
			float d = (diag - (t * 1.5 - 0.25)) / 0.06;
			c.rgb += exp(-d * d) * hair_shine * vec3(0.75, 0.55, 1.0);
		}
	}

	COLOR = vec4(clamp(c.rgb, 0.0, 1.0), c.a);
}
