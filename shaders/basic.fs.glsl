#version 330

in vec2 uv;
in vec3 worldNormal;

void main(void)
{
    gl_FragColor = vec4(abs(worldNormal), 1.0);
}
