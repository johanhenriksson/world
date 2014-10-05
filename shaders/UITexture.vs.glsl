#version 330
uniform mat4 Screen; // Screen -> Clip
uniform mat4 Transform;

in vec3 Vertex;
in vec2 TexCoord;

out vec2 UV;

void main() 
{
    UV = TexCoord;
    gl_Position = (Screen * Transform) * vec4(Vertex, 1.0);
}
