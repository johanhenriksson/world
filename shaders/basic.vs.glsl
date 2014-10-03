#version 330

uniform mat4 Projection;
uniform mat4 View;
uniform mat4 Model;

in vec3 Vertex;
in vec2 TexCoord0;
in vec3 Normal;

out vec2 uv;
out vec3 worldNormal;

void main(void)
{
    worldNormal = Normal;
    uv = TexCoord0;

    gl_Position = (Projection * (View * Model)) * vec4(Vertex, 1);
}
