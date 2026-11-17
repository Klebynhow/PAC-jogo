shader_type canvas_item;

// Animacao do cenario de batalha (arte 256x144):
//  - nuvens andam pelo ceu (pixel a pixel)
//  - rajadas de vento balancam o gramado
//  - sombras de nuvens passam sobre o campo
//  - runas/cristais ciano pulsam
// O "tint" e o modulate original do Sprite2D (o script passa o valor para ca).

uniform vec3 tint = vec3(1.0);
uniform float cloud_speed = 3.0;        // pixels por segundo
uniform float grass_sway = 1.0;         // 0 desliga o balanco do gramado
uniform float shadow_strength = 0.12;   // escurecimento das sombras de nuvem
uniform float glow_pulse = 0.22;        // pulsar das runas ciano

const vec3 SKY = vec3(118.0, 160.0, 211.0) / 255.0;
const vec3 CLOUD_WHITE = vec3(247.0 / 255.0);
const vec3 CLOUD_SHADE = vec3(185.0, 245.0, 241.0) / 255.0;
const float ORB_X0 = 104.0;             // regiao do orbe da torre (nuvens passam por tras)
const float ORB_X1 = 152.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 texel(vec2 p) {
	return texture(TEXTURE, (floor(p) + 0.5) * TEXTURE_PIXEL_SIZE).rgb;
}

bool near(vec3 a, vec3 b) {
	return all(lessThan(abs(a - b), vec3(0.012)));
}

bool is_cloud_color(vec3 c) {
	return near(c, CLOUD_WHITE) || near(c, CLOUD_SHADE);
}

void fragment() {
	vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;      // (256, 144)
	vec2 p = floor(UV * size);
	vec3 col = texel(p);

	// --- nuvens: apaga as originais e redesenha deslocadas
	if (p.y < 20.0) {
		if ((p.x < ORB_X0 || p.x > ORB_X1) && is_cloud_color(col)) {
			col = SKY;
		}
		float sx = mod(p.x - floor(TIME * cloud_speed), size.x);
		if (sx < ORB_X0 || sx > ORB_X1) {
			vec3 s = texel(vec2(sx, p.y));
			if (is_cloud_color(s) && near(col, SKY)) {
				col = s;
			}
		}
	}

	// --- gramado: rajadas de vento deslocam linhas de pixels
	if (grass_sway > 0.0 && p.y >= 57.0) {
		float w = sin(TIME * 1.5 + p.x * 0.08 + p.y * 0.5);
		float limit = (p.y < 78.0) ? 0.6 : 0.82;
		float dx = w > limit ? 1.0 : (w < -limit ? -1.0 : 0.0);
		col = texel(vec2(p.x - dx * grass_sway, p.y));
	}

	// --- sombras de nuvem passando sobre o campo (blocos de 4 px)
	if (p.y >= 58.0) {
		vec2 q = floor(p / 4.0);
		float n = vnoise(vec2(q.x * 0.35 - TIME * 0.35, q.y * 0.5));
		col *= 1.0 - shadow_strength * smoothstep(0.55, 0.75, n);
	}

	// --- runas e cristais ciano pulsando
	vec3 h = rgb2hsv(col);
	if (h.x > 0.46 && h.x < 0.58 && h.y > 0.8 && h.z > 0.5) {
		col *= 1.0 + glow_pulse * sin(TIME * 2.2 + p.x * 0.15);
	}

	COLOR = vec4(clamp(col, 0.0, 1.0) * tint, 1.0);
}
