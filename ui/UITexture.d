module ui.UITexture;

import gl3n.linalg;
import derelict.opengl3.gl;
import geometry;
import material;
import shader;

class UITexture : GLArray
{
    @property Texture GLTexture() { return texture; }

    private Texture texture;
    private vec2 size;
    GLArrayBuffer vertexBuffer;
    GLArrayBuffer texcoordBuffer;

    public this(Texture texture, int width, int height) {
        this.texture = texture;
        this.size = vec2(width, height);
    }

    public void replace(Texture newTexture) {
        texture = newTexture;
    }

    public this(Texture texture) { this(texture, texture.Width, texture.Height); }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float width  = size.x,
              height = size.y;

        float[] vertex = [
            0,      height, 0, 
            0,      0,      0, 
            width,  height, 0, 

            0,      0,      0, 
            width,  0,      0, 
            width,  height, 0, 
        ];

        float[] texcoord = [
            0, 0,
            0, 1,
            1, 0,

            0, 1,
            1, 1,
            1, 0,
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(vertex.length, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        texcoordBuffer = new GLArrayBuffer();
        texcoordBuffer.bufferData(texcoord.length, float.sizeof, cast(void*) texcoord.ptr);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, null); // Position

        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
    }

    public void drawTextured(Shader shader) 
    {
        this.bind();

        glActiveTexture(GL_TEXTURE0);
        texture.bind();
        shader.setInt("Texture", 0);

        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
