module shader.Shader;

import std.string;
import gl3n.linalg;
import derelict.opengl3.gl;
import shader;

class Shader
{
    private uint id;
    private bool linked;

    public this() {
        this.id = glCreateProgram();
    }

    public uint getId() {
        return this.id;
    }

    public void attach(ShaderProgram program) 
    {
        if (!program.isCompiled())
            throw new Exception("Shader program must be compiled first");

        glAttachShader(this.id, program.getId());
    } 

    public void link() 
    {
        /* Bind attribute locations */
        glBindAttribLocation(this.id, 0, "Vertex");
        glBindAttribLocation(this.id, 1, "Normal");
        glBindAttribLocation(this.id, 2, "TexCoord0");

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

    protected uint getUniformLocation(string name) 
    {
        auto cstr = toStringz(name);
        uint loc = glGetUniformLocation(this.id, cstr);
        if (loc == -1)
            throw new Exception(format("Unknown uniform '%s'", name));
        return loc;
    }

    public void setInt(string name, int value) {
        uint loc = getUniformLocation(name);
        glUniform1i(loc, value);
    }

    public void setMatrix4(string name, mat4 mat) {
        uint loc = getUniformLocation(name);
        glUniformMatrix4fv(loc, 1, GL_TRUE, mat.value_ptr);
    }

    public void setVec3(string name, vec3 vec) {
        uint loc = getUniformLocation(name);
        glUniform3fv(loc, 1, vec.value_ptr);
    }
    
    public void setVec4(string name, vec4 vec) {
        uint loc = getUniformLocation(name);
        glUniform4fv(loc, 1, vec.value_ptr);
    }

    /** Factory method */
    public static Shader Create(string shaderName) 
    {
        auto shader   = new Shader();
        auto vertex   = new VertexShader(format("assets/shaders/%s.vs.glsl", shaderName));
        auto fragment = new FragmentShader(format("assets/shaders/%s.fs.glsl", shaderName));

        vertex.compile();
        fragment.compile();

        shader.attach(vertex);
        shader.attach(fragment);
        shader.link();
        return shader;
    }
}
