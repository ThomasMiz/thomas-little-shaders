#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

const float scale = 10.0;
const vec2 offset = vec2(0.0, 0.0);

const float waterTopLevel = 0.45;
const float sandTopLevel = 0.5;
const float grassTopLevel = 0.65;
const float stoneTopLevel = 0.75;
const float mountainTopLevel = 1.0;
const float lavaMinLevel = 0.77;

const float drawDebug = 0.0;

uniform vec2 u_resolution;
uniform float u_time;

float smooth(float min, float max, float v) {
	return min+(max-min)*(3.0*v*v-2.0*v*v*v);
}

vec4 smooth(vec4 min, vec4 max, float v) {
	return min+(max-min)*(3.0*v*v-2.0*v*v*v);
}

float smoother(float min, float max, float v) {
	return min+(max-min)*(6.0*pow(v, 5.0)-15.0*pow(v, 4.0)+10.0*pow(v, 3.0));
}

vec4 rand4d(vec2 c) {
	return fract(sin(vec4(
		dot(c, vec2(52.9258, 76.3911)),
		dot(c, vec2(66.7943, 33.1674)),
		dot(c, vec2(80.4451, 48.4461)),
		dot(c, vec2(69.0420, 42.0699))
	)) * vec4(49164.7641, 69761.6413, 63455.1876, 77846.6674));
}

vec2 rand2d(vec2 c) {
	return fract(sin(vec2(
		dot(c, vec2(52.9258, 76.3911)),
		dot(c, vec2(66.7943, 33.1674))
	)) * vec2(49164.7641, 69761.6413));
}

vec2 noise2d(vec2 c) {
	vec2 fc = fract(c);
	vec2 ic = floor(c);
	vec2 bl = rand2d(ic);
	vec2 br = rand2d(ic + vec2(1.0, 0.0));
	vec2 tl = rand2d(ic + vec2(0.0, 1.0));
	vec2 tr = rand2d(ic + vec2(1.0, 1.0));
	return mix(mix(bl, br, fc.x), mix(tl, tr, fc.x), fc.y);
}

vec2 fbm2d(vec2 c) {
	float amp = 0.5;
	float freq = 1.0;
	vec2 v = vec2(0.0);
    
	for(int i=0; i<8; i++) {
		v += noise2d(c * freq) * amp;
		amp *= 0.5;
		freq *= 2.0;
	}
    
	return v;
}
vec3 terr(vec2 c) {
	vec2 fbmval = fbm2d(c);
	float moistval = fbmval.y;
	float heightval = fbmval.x;
    
	if(heightval < waterTopLevel) {
		//Make water
		float w = heightval / waterTopLevel;
	  return vec3(0.14,0.4, 1.0) * vec3(pow(w*0.5*2.0, 1.2));
	}
    
	if (heightval < sandTopLevel) {
		//Make sand
		float s = (heightval - waterTopLevel) / (sandTopLevel - waterTopLevel);
		float m = floor((moistval*1.8)*4.0)/4.0;
		return mix(vec3(0.7, 0.6, 0.4), vec3(0.94, 0.87, 0.56), m) * vec3(s*0.2+0.8);
	}
    
	if (heightval < grassTopLevel) {
		float g = (heightval - sandTopLevel) / (grassTopLevel - sandTopLevel);
		float m = floor((moistval*1.8)*4.0)/4.0;
		return mix(vec3(0.1, 0.7, 0.0), vec3(0.05, 0.4, 0.0), m);
		return vec3(0.0, 1.0, 0.2);
	}
    
	if (heightval > stoneTopLevel && heightval < mountainTopLevel) {
		float s = (heightval - stoneTopLevel) / (mountainTopLevel - stoneTopLevel);
		if (heightval > lavaMinLevel && abs(moistval-0.13) < 0.25) {
			//LAVA
			return vec3(1.0, 0.1, 0.2) * clamp((pow(s+0.79, 6.0)+0.2), 0.1, 1.3);
		}
		if(abs(moistval-0.72) < 0.25) {
			//SNOW
			return vec3(0.84, 0.9, 1.0) * (s+0.95);
		}
	}
    
	if (heightval < mountainTopLevel) {
		float s = (heightval - grassTopLevel) / (stoneTopLevel - grassTopLevel);
		return vec3(0.5, 0.55, 0.52) * (s*0.35+0.8);
	}
    
	return vec3(1,0,1);
}

vec3 grid(vec2 c) {
	vec2 v = fract(c);
	float x = 2.0 - step(0.02, v.x) - step(0.02, v.y);
	return vec3(x, 0.0, 0.0);
}

void main(void) {
	vec2 c = (gl_FragCoord.xy / u_resolution.x + offset) * scale;
	gl_FragColor = vec4(terr(c), 1.0);
    gl_FragColor.xyz += drawDebug * grid(c);
}