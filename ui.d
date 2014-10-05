import gl3n.linalg;
import derelict.opengl3.gl;

import geometry;
import shader;

class UIManager
{
    UIQuad quad;

    public this() {
        auto shader = Shader.Create("UIColor");

        quad = new UIQuad(shader);
        quad.tesselate();
    }

    public void draw() {
        quad.draw();
    }
}

class UIQuad : GLArray
{
    vec4 color;
    vec3 position;
    vec2 size;

    Shader shader;
    GLArrayBuffer colorBuffer;

    public this(Shader shader) 
    {
        this.shader = shader;
        color    = vec4(1, 0, 0, 1);
        position = vec3(50, 50, 0);
        size     = vec3(100, 100, 0);
    }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float px = position.x,
               py = position.y,
               pz = position.z,
               width  = size.x,
               height = size.y;

        /* Cast float color to bytes */
        ubyte r = cast(ubyte)( color.x * 255 ),
              g = cast(ubyte)( color.y * 255 ),
              b = cast(ubyte)( color.z * 255 ),
              a = cast(ubyte)( color.w * 255 );

        float[] vertex = [
            px + 0,      py + 0,      pz, 
            px + 0,      py + height, pz, 
            px + width,  py + height, pz, 

            px + 0,      py + 0,      pz, 
            px + height, py + 0,      pz, 
            px + width,  py + height, pz, 
        ];
        ubyte[] colors = [
            r, g, b, a, r, g, b, a, r, g, b, a,
            r, g, b, a, r, g, b, a, r, g, b, a,
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(18, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        colorBuffer = new GLArrayBuffer();
        colorBuffer.bufferData(6, ubyte.sizeof, cast(void*) colors.ptr);
        glVertexAttribPointer(1, 4, GL_UNSIGNED_BYTE, GL_TRUE,  0, null); // Color

        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
    }

    public override void draw() 
    {
        shader.use();
        this.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    protected override GLArrayBuffer computeVertexData() { return null; }
    protected override GLArrayBuffer computeTexcoordData() { return null; }
    protected override GLArrayBuffer computeNormalData() { return null; }
    protected override GLElementBuffer computeElementData() { return null; }
}
