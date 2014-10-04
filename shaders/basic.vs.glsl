#version 330

uniform mat4 Projection;
uniform mat4 View;
uniform mat4 Model;
uniform vec3 CameraPos;
uniform vec3 LightPos;

in vec3 Vertex;
in vec2 TexCoord0;
in vec3 Normal;

out vec2 uv;
out vec3 worldNormal;
out vec3 L;
out vec3 V;
out float lightDistance;

void main(void)
{
    mat3 NormalMatrix = mat3(Model); /* no non-uniform scaling, we dont need the inverse transpose */

    worldNormal = NormalMatrix * Normal;
    uv = TexCoord0;

    vec4 worldPos = (Projection * (View * Model)) * vec4(Vertex, 1);
    L = LightPos - worldPos.xyz;
    lightDistance = length(L);
    L = normalize(L);
    V = normalize(CameraPos - worldPos.xyz);

    gl_Position = worldPos;
}
