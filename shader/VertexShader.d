module shader.VertexShader;

import derelict.opengl3.gl;
import shader;

class VertexShader : ShaderProgram {
    this(string sourcePath) {
        super(GL_VERTEX_SHADER, sourcePath);
    }
}
