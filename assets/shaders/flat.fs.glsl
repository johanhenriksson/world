#version 330

uniform sampler2D Texture;

in vec2 uv;
in vec3 normal;
flat in float light;

out vec4 fragColor;

void main(void)
{
    float ambient = 0.25;

    vec4 diffuse = vec4(0.5, 0.5, 0.5, 1.0) + 0.001 * texture(Texture, uv);

    vec4 color = diffuse  * max(0.2, light);

    color.w = 1.0;
    fragColor = color;
}
