import std.string;
import std.file;
import std.stdio;
import derelict.opengl3.gl;

class ShaderProgram
{
    private uint id;
    private bool linked;

    public this() {
        this.id = glCreateProgram();
    }

    public uint getId() {
        return this.id;
    }

    public void attach(Shader shader) 
    {
        if (!shader.isCompiled())
            throw new Exception("Shader must be compiled first");

        glAttachShader(this.id, shader.getId());
    } 

    public void link() 
    {
        glLinkProgram(this.id);

        int isLinked = GL_FALSE;
        glGetProgramiv(this.id, GL_LINK_STATUS, &isLinked);
        if (isLinked == GL_FALSE) {
            int length = 0;
            char[] buffer = new char[1024];
            glGetProgramInfoLog(this.id, 1024, &length, buffer.ptr);
            
            throw new Exception(format("GLSL Link Error: %s", buffer));
        }

        this.linked = true;
    }

    public void use() 
    {
        if (!this.linked)
            throw new Exception("GLSL Shader must be linked first");
        glUseProgram(this.id);
    }
}

class Shader
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

class VertexShader : Shader {
    this(string sourcePath) {
        super(GL_VERTEX_SHADER, sourcePath);
    }
}

class FragmentShader : Shader {
    this(string sourcePath) {
        super(GL_FRAGMENT_SHADER, sourcePath);
    }
}
