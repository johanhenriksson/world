#version 330

uniform sampler2D Texture;

in vec2 UV;

out vec4 FragColor;

void main() {
    FragColor = vec4(UV.xy, 0, 1) + texture(Texture, UV);
}
