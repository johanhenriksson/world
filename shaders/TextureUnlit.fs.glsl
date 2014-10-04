#version 330

uniform sampler2D Texture;

in vec2 UV;

void main(void) {
    glFragColor = texture2D(Texture, UV);
}
