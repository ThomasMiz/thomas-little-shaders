#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

const float scale = 20.0;
const vec2 moveSpeed = vec2(1.0, 1.0);
const float biome = 0.0; // Probar en el rango [0, 5)

const float drawDebug = 0.0;

uniform vec2 u_resolution;
uniform float u_time;

vec2 rotateVector(in vec2 v, float r){
	return vec2(
		cos(r) * v.x - sin(r) * v.y,
		sin(r) * v.x + cos(r) * v.y
	);
}

float rand1d(in vec2 c) {
	return fract(sin(dot(c, vec2(-48.3612, 64.5938) ) ) * 46762.7649167);
}

vec2 rand2d(in vec2 c) {
	return fract(vec2(
		sin(dot(c, vec2(12.9898, 78.233) ) ) * 43758.5453123,
		cos(dot(c, vec2(58.4829,-97.305) ) ) * 63952.3305152
	));
}

vec2 valueFor(vec2 point) {
	return rand2d(point)*2.0-1.0;
}

float qerp(float min, float max, float val){
	return mix(
		min, max,
		pow(val, 3.0)*(val*(val*6.0-15.0)+10.0) //Quintic interpolation
	);
}

vec3 swamp(in float v, in vec2 c){
	if (v > 0.80) return vec3(0.3); //rock
	if (v > 0.64) return vec3(0.2, 0.45, 0.1); //grass
	if (v > 0.53) return vec3(0.1, 0.4, 0.1); //grass dark
	if (v > 0.49) return vec3(0.0, 0.3, 0.2); //moss
	if (v > 0.41) return vec3(0.1, 0.2, 0.5); //water
	return vec3(0.1, 0.15, 0.5); //water dark
}

vec3 desert(in float v, in vec2 c){
	if (v < 0.33) return vec3(0.4, 0.3, 1.0); //water
	if (v < 0.37) return vec3(0.78, 0.62, 0.31); //wet sand
	if (v < 0.43) return vec3(0.82, 0.67, 0.36); //sandstone
	if (v < 0.6) return vec3(0.85, 0.7, 0.4); //sand
	return vec3(0.88, 0.76, 0.6);
}

vec3 plains(in float v, in vec2 c) {
	if (v < 0.4) return vec3(0.1, 0.2, 0.8); //water
	if (v < 0.43) return vec3(0.4, 0.3, 0.2); //dirt
	if (v < 0.47) return vec3(0.3, 0.75, 0.35); //wet grass
	if (v < 0.6) return vec3(0.4, 0.8, 0.4); // grass
	return vec3(0.45, 0.85, 0.45); //bright grass
}

vec3 tundra(in float v, in vec2 c){
	if (v < 0.38) return vec3(0.5, 0.6, 0.9) + step(fract(c.x-0.5*c.y), 0.5)*vec3(0.1); //ice
	if (v < 0.45) return vec3(0.8, 0.8, 0.9);
	if (v < 0.67) return vec3(0.9, 0.9, 1.0);
	return vec3(0.7, 0.7, 0.8);
}

vec3 mountains(in float v, in vec2 c) {
	if (v < 0.4) return vec3(0.2, 0.3, 0.8);
	if (v < 0.45) return vec3(0.35, 0.9, 0.4);
	return vec3(floor((v-0.45)*20.0)*0.09+0.6);
}

vec3 grid(vec2 c) {
	vec2 v = fract(c);
	float x = 2.0 - step(0.02, v.x) - step(0.02, v.y);
	return vec3(x, 0.0, 0.0);
}

void main(void) {
	vec2 c = gl_FragCoord.xy / u_resolution.y;
	c *= scale;
	c += u_time * moveSpeed;
    
	vec2 fc = fract(c);
	vec2 ic = floor(c);
	vec2 bl = valueFor(ic);
	vec2 br = valueFor(vec2(ic.x+1.0, ic.y));
	vec2 tl = valueFor(vec2(ic.x, ic.y+1.0));
	vec2 tr = valueFor(vec2(ic.x+1.0, ic.y+1.0));

	float toplerp = qerp(
		dot(bl, fc - vec2(0.0, 0.0)),
		dot(br, fc - vec2(1.0, 0.0)),
		fc.x
	);
    
	float bottomlerp = qerp(
		dot(tl, fc - vec2(0.0, 1.0)),
		dot(tr, fc - vec2(1.0, 1.0)),
		fc.x
	);

	float v = qerp(toplerp, bottomlerp, fc.y) * 0.5 + 0.5;
    
    vec3 biomeColor = biome < 1.0 ? swamp(v, c)
        : biome < 2.0 ? desert(v, c)
        : biome < 3.0 ? plains(v, c)
        : biome < 4.0 ? tundra(v, c) : mountains(v, c);

	gl_FragColor = vec4(biomeColor, 1.0);
    gl_FragColor.xyz += drawDebug * grid(c);
}