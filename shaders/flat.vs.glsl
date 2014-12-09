#version 330

uniform mat4 Projection;
uniform mat4 View;
uniform mat4 Model;
uniform vec3 CameraPos;
uniform vec3 LightPos;

in vec3 Vertex;
in vec2 TexCoord0;
in vec3 Normal;
out vec3 normal;

out vec2 uv;
flat out float light;

void main(void)
{
    mat3 NormalMatrix = mat3(Model); /* no non-uniform scaling, we dont need the inverse transpose */

    vec3 worldNormal = NormalMatrix * Normal;
    uv = TexCoord0;

    vec4 worldPos = Model * vec4(Vertex, 1);
    vec3 L = LightPos - worldPos.xyz;
    float lightDistance = length(L);
    L = normalize(L);
    vec3 V = normalize(CameraPos - worldPos.xyz);

    normal = normalize(worldNormal);

    float intensity = 5.6;
    light = intensity / pow(lightDistance, 2) * (1.0 + 0.001 * max(0, dot(L, normal)));

    gl_Position = Projection * (View * worldPos);
}
