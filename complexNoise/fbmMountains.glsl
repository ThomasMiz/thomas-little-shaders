#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

const float scale = 6.0;
const vec2 offset = vec2(0.0, 0.0);
const float force = 0.304;
const float baseOffset = 1.4;
const float baseMultiplier = 1.7;
const float baseHeight = 0.5;

const float drawDebug = 0.0;

uniform vec2 u_resolution;
uniform float u_time;

float mixs(float min, float max, float v) {
	return mix(min, max, v*v*(3.0-2.0*v));
}

vec4 rand4d(vec2 c) {
	return fract(sin(vec4(
		dot(c, vec2(12.864, 27.391)),
		dot(c, vec2(08.293, 23.881)),
		dot(c, vec2(13.532, 18.443)),
		dot(c, vec2(26.703, 09.324))
	))* vec4(58197.4, 62361.7, 57193.5, 60887.3));
}

float altrand(vec2 c) {
	vec4 r = rand4d(c);
	float x = u_time * (r.w+0.5)+ r.z;
	float wav = x-2.0*max(2.0*(x*0.5-floor(x*0.5))-1.0, 0.0) - 2.0*floor(0.5*x);
	return mix(r.x, r.y, wav);
}

float noise(vec2 c) {
	vec2 fl = floor(c);
	vec2 fr = fract(c);
	float bl = altrand(fl);
	float br = altrand(vec2(fl.x + 1.0, fl.y));
	float tl = altrand(vec2(fl.x, fl.y + 1.0));
	float tr = altrand(fl + vec2(1, 1));

	return mixs(
		mixs(bl, br, fr.x),
		mixs(tl, tr, fr.x),
		fr.y
	);
}

float fbm(vec2 c) {
	float v = 0.0;
	float freq = 1.0;
	float amp = 0.5;
	for(int i=0; i<7; i++) {
		v += noise(c*freq) * amp;
		freq *= 2.0;
		amp *= 0.5;
	}
	return v;
}

float mountains(vec2 c) {
	return baseOffset - baseMultiplier * pow(abs(fbm(c)-baseHeight), force);
}

vec3 grid(vec2 c) {
	vec2 v = fract(c);
	float x = 2.0 - step(0.02, v.x) - step(0.02, v.y);
	return vec3(x, 0.0, 0.0);
}

void main(void) {
	vec2 c = (gl_FragCoord.xy / u_resolution.x + offset) * scale;
	gl_FragColor = vec4(mountains(c));
    gl_FragColor.xyz += drawDebug * grid(c);
}