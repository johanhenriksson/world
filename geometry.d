import derelict.opengl3.gl;
import gl3n.linalg;

/* for debug */
import std.stdio;

abstract class GLArray 
{
    private uint vao;

    protected GLArrayBuffer vertexBuffer;
    protected GLArrayBuffer normalBuffer;
    protected GLArrayBuffer texcoordBuffer;
    protected GLElementBuffer indexBuffer;

    public this() {
        /* Create vertex array object */
        glGenVertexArrays(1, &this.vao);
    }

    public uint getId() {  
        return this.vao; 
    }

    public void bind() {
        glBindVertexArray(this.vao);
    }

    /* Generate & upload geometry */
    public void tesselate() 
    {
        this.bind();

        /* Compute & upload mesh data */
        vertexBuffer = computeVertexData();
        normalBuffer = computeNormalData();
        texcoordBuffer = computeTexcoordData();
        indexBuffer  = computeElementData();

        /* Position pointer */
        vertexBuffer.bind();
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        /* Normal pointer */
        normalBuffer.bind();
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_TRUE,  0, null); // Normal

        /* Texcoord pointer */
        texcoordBuffer.bind();
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, null); // Texcoord

        /* Enable */
        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
        glEnableVertexAttribArray(2);
    }

    public void draw() {
        bind();
        indexBuffer.draw();
    }

    protected abstract GLArrayBuffer computeVertexData();
    protected abstract GLArrayBuffer computeTexcoordData();
    protected abstract GLArrayBuffer computeNormalData();
    protected abstract GLElementBuffer computeElementData(); 
}

class IsoCube : GLArray
{
    protected override GLArrayBuffer computeVertexData() 
    {
        vec3[] points = [ 
            vec3(0,0,-1), vec3(0,0,0), vec3(0,0,0), vec3(1,0,0), 
            vec3(0,1,-1), vec3(0,1,0), vec3(0,1,0), vec3(1,1,0), 
            vec3(0,1,-1), vec3(0,1,0), vec3(1,1,0), vec3(1,1,-1) 
        ];

        /* Center offset */
        for(auto i = 0; i < points.length; i++) 
            points[i] = points[i] - vec3(0.5f, 0.5f, 0.5f);

        auto vb = new GLArrayBuffer();
        vb.bind();
        vb.bufferData(points.length * 3, float.sizeof, cast(void*) points.ptr);
        return vb;
    }

    protected override GLArrayBuffer computeNormalData() 
    {
        vec3[] normal = [ 
            vec3(-1,0,0), vec3(-1,0,0), vec3(0,0,-1), vec3(0,0,-1), 
            vec3(-1,0,0), vec3(-1,0,0), vec3(0,0,-1), vec3(0,0,-1), 
            vec3(0,1,0),  vec3(0,1,0),  vec3(0,1,0),  vec3(0,1,0),
        ];

        auto nb = new GLArrayBuffer();
        nb.bind();
        nb.bufferData(normal.length * 3, float.sizeof, cast(void*) normal.ptr);
        return nb;
    }

    protected override GLArrayBuffer computeTexcoordData() 
    {
        vec2[] coords = [
            vec2(0,0), vec2(1,0), vec2(0,0), vec2(1,0),
            vec2(0,1), vec2(1,1), vec2(0,1), vec2(1,1),
            vec2(0,1), vec2(0,0), vec2(1,0), vec2(1,1),
        ];

        auto tb = new GLArrayBuffer();
        tb.bind();
        tb.bufferData(coords.length * 2, float.sizeof, cast(void*) coords.ptr);
        return tb;
    }

    protected override GLElementBuffer computeElementData() 
    {
        ushort[] idx = [
            11, 8, 9, 11, 9, 10, // Top Left, Right
            4,  1, 5, 4,  0, 1,  // Left Top, Bottom
            6,  2, 7, 7,  2, 3,  // Right Top, Bottom
        ];

        auto ib = new GLElementBuffer(GL_UNSIGNED_SHORT);
        ib.bind();
        ib.bufferData(idx.length, ushort.sizeof, cast(void*) idx.ptr);
        return ib;
    }
}

class Quad : GLArray
{
    private float size_x;
    private float size_y;
    private int width;
    private int height;
    private int pw;
    private int ph;

    GLArrayBuffer   texcord;
    GLArrayBuffer   vertex;
    GLElementBuffer index;

    public this(float width, float height) {
        this(width, height, 1, 1);
    }

    public this(float size_x, float size_y, int seg_x, int seg_y) 
    {
        this.width  = seg_x;
        this.height = seg_y;
        this.size_x = size_x;
        this.size_y = size_y;

        this.pw = width + 1;
        this.ph = height + 1;
    }


    protected override GLArrayBuffer computeVertexData() 
    {
        int i = 0;
        float sx = size_x / width,
              sy = size_y / height,
              half_w = size_x / 2.0f,
              half_h = size_y / 2.0f;

        vec3[] points = new vec3[pw * ph];
        for (int x = 0; x < pw; x++) 
            for (int y = 0; y < ph; y++) {
                points[i++] = vec3(x * sx, y * sy, 0);
                writefln("vx %d - x: %f y: %f", i-1, x*sx, y*sy);
            }

        auto vb = new GLArrayBuffer();
        vb.bind();
        vb.bufferData(points.length * 3, float.sizeof, cast(void*) points.ptr);
        return vb;
    }

    protected override GLArrayBuffer computeNormalData() 
    {
        int count = pw * ph;
        vec3[] normal = new vec3[count];
        for(int i = 0; i < count; i++) 
            normal[i] = vec3(0,1,0);

        auto nb = new GLArrayBuffer();
        nb.bind();
        nb.bufferData(normal.length * 3, float.sizeof, cast(void*) normal.ptr);
        return nb;
    }

    protected override GLArrayBuffer computeTexcoordData() 
    {
        int count = pw * ph,
            i = 0;
        float sx  = 1.0f / ph,
              sy  = 1.0f / ph; 

        vec3[] coords = new vec3[pw * ph];
        for (int x = 0; x < pw; x++) 
            for (int y = 0; y < ph; y++) {
                coords[i++] = vec3(x * sx, y * sy, 0);
                writefln("tx %d - x: %f y: %f", i-1, x*sx, y*sy);
            }

        auto tb = new GLArrayBuffer();
        tb.bind();
        tb.bufferData(coords.length * 2, float.sizeof, cast(void*) coords.ptr);
        return tb;
    }

    protected override GLElementBuffer computeElementData() 
    {
        int i = 0;
        ushort[] idx = new ushort[width * height * 6];
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                idx[i++] = cast(ushort)( x*ph + y + 1 ); // tl 
                idx[i++] = cast(ushort)( x*ph + y ); // bl
                idx[i++] = cast(ushort)((x+1)*ph + y ); // br

                idx[i++] = cast(ushort)( x*ph + y + 1 ); // tl 
                idx[i++] = cast(ushort)((x+1)*ph + y ); // br
                idx[i++] = cast(ushort)((x+1)*ph + y+1 ); // tr
            }
        }

        auto ib = new GLElementBuffer(GL_UNSIGNED_SHORT);
        ib.bind();
        ib.bufferData(idx.length, ushort.sizeof, cast(void*) idx.ptr);
        return ib;
    }

}

class GLBuffer
{
    private uint id;
    private uint type;
    private uint storageType;
    private ulong elements;

    public this(uint type) 
    {
        this.type = type;
        this.storageType = GL_STATIC_DRAW;
        glGenBuffers(1, &this.id);
    }

    public void bind() {
        glBindBuffer(this.type, this.id);        
    }

    public void bufferData(ulong elements, ulong size, void* ptr) {
        this.elements = elements;
        writeln(format("Buffering %d elements (each: %d, total %d)", 
            elements,
            size,
            elements * size
        ));
        this.bind();
        glBufferData(this.type, elements * size, ptr, this.storageType);
    }
}

class GLArrayBuffer : GLBuffer
{
    public this() {
        super(GL_ARRAY_BUFFER);
    }
}

class GLElementBuffer : GLBuffer
{
    uint primitive;
    uint dataType;

    public this(uint datatype) {
        super(GL_ELEMENT_ARRAY_BUFFER);
        this.primitive = GL_TRIANGLES;
        this.dataType = datatype;
    }

    public void draw() {
        glDrawElements(this.primitive, cast(int) this.elements, this.dataType, null);
    }
}
