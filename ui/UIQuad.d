module ui.UIQuad;

import gl3n.linalg;
import derelict.opengl3.gl;
import shader;
import geometry;

class UIQuad : GLArray
{
    @property vec4 Color() { return color; }
    @property vec2 Size()  { return size; }

    @property vec4 Color(vec4 value) { return color = value; }
    @property vec2 Size(vec2 value)  { return size  = value; }

    vec4 color;
    vec2 size;
    GLArrayBuffer vertexBuffer;

    public this(vec2 size, vec4 color)
    {
        this.color = color;
        this.size = size;
    }

    public ~this() {
        delete vertexBuffer;
    }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float width  = size.x,
              height = size.y;

        float[] vertex = [
            0,      0,      0, 
            0,      height, 0, 
            width,  height, 0, 

            0,      0,      0, 
            width,  0,      0, 
            width,  height, 0, 
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(vertex.length, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        glEnableVertexAttribArray(0);
    }

    public void drawColored(Shader shader) 
    {
        shader.setVec4("Color", this.color);
        this.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}
