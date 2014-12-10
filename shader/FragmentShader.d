module shader.FragmentShader;

import derelict.opengl3.gl;
import shader;

class FragmentShader : ShaderProgram {
    this(string sourcePath) {
        super(GL_FRAGMENT_SHADER, sourcePath);
    }
}
