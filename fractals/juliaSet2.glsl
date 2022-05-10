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
    float mi = .4675, ma = .5;
    vec2 c = vec2(Wave(mi, ma, 0.2), 0.0);
    for (int i = 0; i < 500; i++) {
        v = CMult(CMult(CMult(v, v), v), vec2(0.5, -0.5));
        v -= CMult(CMult(v, v), vec2(1.0, -1.0));
        v += CMult(v, vec2(1.0, -0.5));
        v += c;

        float d = abs(v.x + v.y);
        if (d > 10.0)
            return vec3(float(i) / 10.0, float(i) / 30.0, float(i) / 100.0);
    }
    return vec3(0, 0, 0);
}

void main(void) {
    vec2 pos = gl_FragCoord.xy / u_resolution.x;
    pos = pos * 1.6 - vec2(0.8, 0.7);

    gl_FragColor = vec4(Jul(pos), 1);
}