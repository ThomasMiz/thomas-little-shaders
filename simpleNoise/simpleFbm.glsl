#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float rand1d(in vec2 c) {
    return fract(sin(dot(c, vec2(68.27505, -15.92843))) * 69193.8491);
}

float noise(in vec2 c) {
    vec2 fr = fract(c);
    
    float bl = rand1d(floor(c));
    float br = rand1d(floor(c + vec2(1.0, 0.0)));
    float tl = rand1d(floor(c + vec2(0.0, 1.0)));
    float tr = rand1d(floor(c + vec2(1.0, 1.0)));
    
    return mix(
    	mix(bl, br, fr.x),
        mix(tl, tr, fr.x),
        fr.y
    );
}

float fbm(in vec2 c) { // Fractal Brownian Motion
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

void main() {
    vec2 c = gl_FragCoord.xy/u_resolution.xy * 10.0;
	c += vec2(-0.550,0.660);
    
    vec3 color = vec3(fbm(c));

    gl_FragColor = vec4(color,1.0);
}