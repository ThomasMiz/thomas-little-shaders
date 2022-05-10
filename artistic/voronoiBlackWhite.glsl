#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

const float scale = 5.0;
const vec2 offset = vec2(0.0, 0.0);

const float drawDebug = 0.0;

uniform vec2 u_resolution;
uniform float u_time;

vec2 rand2d(in vec2 c) {
	return fract(sin(vec2(
		dot(c, vec2(52.9258, 76.3911)),
		dot(c, vec2(66.7943, 33.1674))
	)) * vec2(49164.7641, 69761.6413));
}

float rand1d(in vec2 c) {
	return fract(sin(dot(c, vec2(44.7731, 57.2496)))* 51933.4912);
}

vec2 calcPointFor(in vec2 fl) {
	return fl + rand2d(fl) * 0.8 + 0.1;
}

vec3 voronoi(in vec2 c) {
	vec2 fl = floor(c);
	vec2 cl1, cl2, cl1p, cl2p;
	float cl1d = 999.0, cl2d;
	for (float dx = -1.0; dx < 2.0; dx++) {
		for (float dy = -1.0; dy < 2.0; dy++) {
        	vec2 f = fl + vec2(dx, dy);
			vec2 p = calcPointFor(f);
            float dist = distance(p, c);
            if (dist < cl1d) {
                cl2 = cl1;
                cl2d = cl1d;
                cl2p = cl1p;
                cl1 = f;
                cl1d = dist;
                cl1p = p;
            }
        }
    }
    
    if (cl2d - cl1d < 0.1)
        return vec3(0.0);

    float rot = rand1d(cl1) * 3.1416 + u_time*0.1;
    vec2 dir = vec2(cos(rot), sin(rot));
    dir = dir * (c-cl1p) * 100.0;
    return sin(dir.x + dir.y) < 0.0 ? vec3(0.4) : vec3(1.0);
}

vec3 grid(vec2 c) {
	vec2 v = fract(c);
	float x = 2.0 - step(0.02, v.x) - step(0.02, v.y);
	return vec3(x, 0.0, 0.0);
}

void main(void) {
	vec2 c = (gl_FragCoord.xy / u_resolution.x + offset) * scale;
	gl_FragColor = vec4(voronoi(c), 1.0);
	gl_FragColor.xyz += drawDebug * grid(c);
}