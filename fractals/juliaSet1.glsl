precision highp float;

uniform vec2 u_resolution;
uniform float u_time;

// Mandelbrot Set Shader
// Uses vec2 to simulate complex numbers.
// x is real, y is lateral/imaginary

float Wave(float min, float max) {
    return min + (max - min) * (sin(u_time) + 1.0) * 0.5;
}
float Wave(float min, float max, float tm) {
    return min + (max - min) * (sin(u_time * tm) + 1.0) * 0.5;
}

vec2 CMult(vec2 a, vec2 b) {
    // Complex number multiplction
    float r = (a.x * b.x) - (a.y * b.y);
    float i = (a.x * b.y) + (a.y * b.x);
    return vec2(r, i);
}

vec3 Jul(vec2 v) {
    float spd = 0.5;
    float ma = .27, mi = .264;
    vec2 c = vec2(Wave(mi, ma, spd), 0.0);
    for (int i = 0; i < 300; i++) {
        v = CMult(v, v) + CMult(vec2(0.1, -0.5), v) + c;
        float d = abs(v.x + v.y);
        if (d > 10.0)
            return vec3(float(i) / 100.0, float(i) / 150.0, float(i) / 50.0);
    }
    return vec3(0, 0, 0);
}

void main(void) {
    vec2 pos = gl_FragCoord.xy / u_resolution.x;
    pos = pos * 2.0 - vec2(1.2, 1.0);
    gl_FragColor = vec4(Jul(pos), 1.0);
}