#version 330

uniform sampler2D texture;

in vec2 uv;
in vec3 worldNormal;

void main(void)
{
    vec4 diffuse = texture2D(texture, uv);

    gl_FragColor = diffuse;
}
