#version 330

uniform mat4 Projection;
uniform mat4 Model;

in vec3 Vertex;
in vec2 TexCoord;

out vec3 UV;

void main(void) {
    UV = TexCoord;
    gl_Position = (Projection * Model) * Vertex;
}
