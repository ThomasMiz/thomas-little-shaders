#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

const float scale = 3.0;
const vec2 offset = vec2(0.0,0.0);
const vec2 tileSize = vec2(150, 100);

const float drawDebug = 0.0;

float rand_a(in vec2 c) {
    return fract(sin(dot(c,
    	vec2(12.9898, 78.233))) * 43758.5453123);
}

float rand_b(in vec2 c) {
	return fract(sin(dot(c, vec2(52.9258, 76.3911))) * 49164.7641);
}

float rand_c(in vec2 c) {
	return fract(sin(dot(c, vec2(66.7943, 33.1674))) * 69761.6413);
}

vec3 calcTintFor(float rand) {
	return vec3(rand*0.5+0.3);
}

vec3 bricks(vec2 c) {
	vec2 tile = floor(c / tileSize) * tileSize;
	float transY = tile.y + rand_b(vec2(0.0, tile.y))*tileSize.y*0.9;
	tile.y += step(transY, c.y) * tileSize.y;
	vec2 bl = tile;
	vec2 tr = bl + tileSize;
	vec2 br = vec2(tr.x, bl.y);
	float blr = rand_a(bl);
	float transX = mix(bl.x, tr.x, blr*0.9);
	float colorSeed = rand_c(c.x < transX ? bl : br);
	return calcTintFor(colorSeed);
}

vec3 grid(vec2 c) {
	vec2 v = fract(c / tileSize);
	float x = 2.0 - step(0.02, v.x) - step(0.02, v.y);
	return vec3(x, 0.0, 0.0);
}

void main(void) {
	vec2 c = (gl_FragCoord.xy + offset*tileSize) * scale;
	vec3 color = bricks(c) + grid(c)*drawDebug;
	gl_FragColor = vec4(color, 1.0);
}