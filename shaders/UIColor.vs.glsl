#version 330
uniform mat4 Screen; // Screen -> Clip

in vec3 Vertex;
in vec4 Color;

out vec4 VertexColor;

void main() 
{
    VertexColor = Color;
    gl_Position = Screen * vec4(Vertex, 1.0);
}
