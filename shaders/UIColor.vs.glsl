#version 330
uniform mat4 Screen; // Screen -> Clip
uniform mat4 Transform;

in vec3 Vertex;

void main() 
{
    gl_Position = (Screen * Transform) * vec4(Vertex, 1.0);
}
