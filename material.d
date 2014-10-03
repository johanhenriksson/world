import std.string;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

import shader;

class Texture
{
    @property uint Id() { return id; }

    uint id;

    public this() {
        glGenTextures(1, &id);
    }

    public this(string path) {
        this();
        load(path);
    }

    public void bind() {
        glBindTexture(GL_TEXTURE_2D, this.id);
    }

    public void load(string path)
    {
        bind(); 

        /* Load image */
        auto surface = IMG_Load(toStringz(path));
        if (surface == null)
            throw new Exception("Could not load texture file: " ~ path);

        /* Upload texture data */
        glTexImage2D(
            GL_TEXTURE_2D, 0, GL_RGBA, 
            surface.w, surface.h, 0, 
            GL_RGB, GL_UNSIGNED_BYTE, 
            surface.pixels
        );

        SDL_FreeSurface(surface);

        /* Mipmap generation */
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 4);
        glGenerateMipmap(GL_TEXTURE_2D);

        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    }
}

class Material
{
    @property ShaderProgram Shader() { return shader; }

    @property Texture Diffuse() { return diffuse; }
    @property Texture Diffuse(Texture value) { return diffuse = value; }

    private ShaderProgram shader;
    
    /* Texture maps */
    private Texture diffuse;
    private Texture normal;
    private Texture specular;

    public this(ShaderProgram shader) {
        this.shader = shader;
    }

    public void use() 
    {
        /* Diffuse */
        glActiveTexture(GL_TEXTURE0);
        diffuse.bind();
        glUniform1i(diffuse.Id, 0);

        /* Normal */
        /* Specular */
    }
}
