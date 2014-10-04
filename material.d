import std.string;
import std.stdio;
import gl3n.linalg;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.sdl2.image;

import shader;

class Texture
{
    @property uint Id() { return id; }
    @property int Width() { return width; }
    @property int Height() { return height; }

    /* Properties */
    uint id;
    int width;
    int height;

    /* GL Settings */
    uint minifyFilter = GL_LINEAR;
    uint magnifyFilter = GL_LINEAR;
    int mipMinLevel = 0;
    int mipMaxLevel = 4;

    public this() 
    {
        glGenTextures(1, &id);

        /* Texture Parameters */
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minifyFilter); 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magnifyFilter); 

        width = 0;
        height = 0;
    }

    public this(string path) {
        this();
        loadFromFile(path);
    }

    public this(SDL_Surface* surface) {
        this();
        loadFromSurface(surface);
    }

    /* Destructor */
    public ~this() {
        /* Free GPU memory */
        glDeleteTextures(1, &this.id);
    }

    public void bind() {
        glBindTexture(GL_TEXTURE_2D, this.id);
    }

    public void generateMipmaps() 
    {
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, mipMinLevel);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL,  mipMaxLevel);
        glGenerateMipmap(GL_TEXTURE_2D);
    }

    public void loadFromSurface(SDL_Surface* surface) 
    {
        this.bind();

        this.width = surface.w;
        this.height = surface.h;

        /* Upload texture data */
        glTexImage2D(
            GL_TEXTURE_2D, 0, GL_RGBA, 
            surface.w, surface.h, 0, 
            GL_RGB, GL_UNSIGNED_BYTE, 
            surface.pixels
        );

        generateMipmaps();
    }

    public void loadFromFile(string path)
    {
        /* Load image */
        auto surface = IMG_Load(toStringz(path));
        if (surface == null)
            throw new Exception("Could not load texture file: " ~ path);

        loadFromSurface(surface);
        SDL_FreeSurface(surface);
    }
}

class TTFTexture : Texture
{
    @property string Text() { return text; }

    protected string text;
    protected vec4 color = vec4(1,0,0,1);

    protected void refresh() {
    }

    protected void render(string text) {
    }
}

class Font
{
    protected TTF_Font* ttf_font;
    protected int size;

    public this(string path, int point_size) 
    {
        auto cstr = toStringz(path);
        ttf_font = TTF_OpenFont(cstr, 20);
        if (!ttf_font)
            throw new Exception(format("Could not load ttf font: %s", path));
    }

    public Texture Render(string text, vec4 color) 
    {
        /* Convert arguments */
        SDL_Color sdl_color = {
            cast(ubyte)( color.x * 255 ), // R
            cast(ubyte)( color.y * 255 ), // G
            cast(ubyte)( color.z * 255 ), // B
            cast(ubyte)( color.w * 255 ), // A
        };
        auto cstr = toStringz(text);

        /* Render to texture */
        auto surface = TTF_RenderText_Blended(ttf_font, cstr, sdl_color);
        auto texture = new Texture(surface);
        SDL_FreeSurface(surface);
        return texture;
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
