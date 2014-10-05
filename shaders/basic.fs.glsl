#version 330

uniform sampler2D Texture;

in vec2 uv;
in vec3 worldNormal;
in vec3 L;
in vec3 V;
in float lightDistance;

out vec4 fragColor;

void main(void)
{
    float ambient = 0.25;
    float intensity = 5.6;

    vec4 diffuse = texture(Texture, uv);

    /* super simple lighting */
    float light = intensity / pow(lightDistance, 2) * max(0, dot(L, worldNormal));

    /* ambient minimum */
    light = max(ambient, light);

    vec4 color = diffuse  * light;

    color.w = 1.0;
    fragColor = color;
}
