#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float rand(in vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec3 hsv2rgb(in vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

// Calculates the point of a square given it's top left
vec2 pointFor(in vec2 tl) {
    return tl + 0.5 + 0.3 * vec2(sin(u_time * (0.5 + rand(tl))), cos(u_time * (0.5 + rand(tl.yx))));
}

// Calculates the color for a given point
vec3 colorFor(in vec2 point) {
    return hsv2rgb(vec3(u_time * 0.2 + (point.x + point.y) * 0.1, 1.0, 1.0));
}

mat2 rotateMat(float r) {
    return mat2(cos(r), sin(r), -sin(r), cos(r));
}

vec2 transform(vec2 c) {
    c /= u_resolution.y;
    vec2 t = vec2(0.5 * u_resolution.x / u_resolution.y, 0.5);
    c -= t;
    c *= rotateMat(u_time * 0.2);
    c += t;
    c *= 6.0;
    return c;
}

void main() {
    vec2 c = transform(gl_FragCoord.xy);
    vec2 ic = floor(c);
    vec2 fc = fract(c);

    vec2 closest;
    float mindist = 16.0;

    for (float x = -1.0; x < 2.0; x++) {
        for (float y = -1.0; y < 2.0; y++) {
            vec2 p = pointFor(ic + vec2(x, y));
            float dist = distance(p, c);
            if (dist < mindist) {
                mindist = dist;
                closest = p;
            }
        }
    }

    gl_FragColor = vec4(colorFor(closest) * (0.666 + 0.333 * fract(-u_time + mindist * 5.1)), 1.0);
}