import derelict.opengl3.gl;
import gl3n.linalg;

/* for debug */
import std.stdio;

struct Vertex {
    vec3 pos;
    vec3 n;
    vec2 uv;
}

/*
        glBindBuffer(GL_ARRAY_BUFFER, vbo);

        glEnableVertexAttribArray(position);
        glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 0, null);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, null);

        glDisableVertexAttribArray(position);
*/

void tri(vec3 a, vec3 b, vec3 c) {
    writeln(format("Tri (%f,%f,%f)", a.x, a.y, a.z));
    writeln(format("    (%f,%f,%f)", b.x, b.y, b.z));
    writeln(format("    (%f,%f,%f)", c.x, c.y, c.z));
}

class Quad
{
    private uint vao;
    private int width;
    private int height;

    GLArrayBuffer   vertex;
    GLElementBuffer index;

    public this(int width, int height) {
        this.width = width;
        this.height = height;
    }

    /* Generate & upload geometry */
    public void tesselate() 
    {
        vec3[] points = new vec3[(width+1)*(height+1)]; 
        for (int x = 0; x < width + 1; x++) {
            for (int y = 0; y < height + 1; y++) {
                int i = x * (height+1) + y;
                points[i] = vec3(x*0.5f,y*0.5f,0);
            }
        }

        int i = 0;
        int h = this.height;
        ushort[] idx = new ushort[width * height * 6];
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                idx[i++] = cast(ushort)( x*(h+1) + y + 1 ); // tl 
                idx[i++] = cast(ushort)( x*(h+1) + y ); // bl
                idx[i++] = cast(ushort)((x+1)*(h+1) + y ); // br

                tri(points[idx[i-3]], points[idx[i-2]], points[idx[i-1]]);

                idx[i++] = cast(ushort)( x*(h+1) + y + 1 ); // tl 
                idx[i++] = cast(ushort)((x+1)*(h+1) + y ); // br
                idx[i++] = cast(ushort)((x+1)*(h+1) + y+1 ); // tr

                tri(points[idx[i-3]], points[idx[i-2]], points[idx[i-1]]);
            }
        }

        /* Create vertex array object */
        glGenVertexArrays(1, &this.vao);
        glBindVertexArray(this.vao);

        /* Upload data */
        auto vb = new GLArrayBuffer();
        vb.bind();
        vb.bufferData(points.length * 3, float.sizeof, cast(void*) points.ptr);

        auto ib = new GLElementBuffer(GL_UNSIGNED_SHORT);
        ib.bind();
        ib.bufferData(idx.length, ushort.sizeof, cast(void*) idx.ptr);

        /* Store position pointer */
        vb.bind();
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
        glEnableVertexAttribArray(0);

        this.vertex = vb;
        this.index  = ib;
    }

    public void draw() {
        //glBindVertexArray(this.vao);
        this.vertex.bind();
        this.index.bind();
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);
        glEnableVertexAttribArray(0);
        this.index.draw();
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
