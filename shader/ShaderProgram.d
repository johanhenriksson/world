module shader.ShaderProgram;

import std.stdio;
import std.file;
import std.string;
import gl3n.linalg;
import derelict.opengl3.gl;
import shader;

class ShaderProgram
{
    uint id;
    uint type;
    string path;
    bool compiled;

    this(uint type, string sourcePath) 
    {
        this.type = type;
        this.path = sourcePath;
        this.compiled = false;

        this.id = glCreateShader(type);
    }

    public uint getId() {
        return this.id;
    }

    void compile() {
        string source = readText(this.path);
        auto cstr = toStringz(source);

        /* Upload source & compile */
        glShaderSource(this.id, 1, &cstr, null);
        glCompileShader(this.id);

        int success = GL_FALSE;
        glGetShaderiv(this.id, GL_COMPILE_STATUS, &success);
        if (success == GL_FALSE) {
            int length = 0;
            char[] buffer = new char[1024];
            glGetShaderInfoLog(this.id, 1024, &length, buffer.ptr);

            throw new Exception(format("GLSL error in %s: %s", this.path, buffer));
        }

        this.compiled = true;
    }

    public bool isCompiled() {
        return this.compiled;
    }   
}
