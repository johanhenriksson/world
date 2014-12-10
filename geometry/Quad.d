module geometry.Quad;

import std.stdio;
import gl3n.linalg;
import derelict.opengl3.gl;
import geometry;

class Quad : GeometryObject
{
    protected float size_x;
    protected float size_z;
    protected int seg_x;
    protected int seg_z;
    protected int px;
    protected int pz;

    GLArrayBuffer   texcord;
    GLArrayBuffer   vertex;
    GLElementBuffer index;

    public this(float size_x, float size_z) {
        this(size_x, size_z, 1, 1);
    }

    public this(float size_x, float size_z, int seg_x, int seg_z) 
    {
        this.seg_x  = seg_x;
        this.seg_z  = seg_z;
        this.size_x = size_x;
        this.size_z = size_z;

        this.px = seg_x + 1;
        this.pz = seg_z + 1;
    }

    protected override GLArrayBuffer computeVertexData() 
    {
        int i = 0;
        float sx = size_x / seg_x,
              sz = size_z / seg_z;

        vec3[] points = new vec3[px * pz];
        for (int x = 0; x < px; x++) {
            for (int z = 0; z < pz; z++) {
                // Lookup height
                points[i++] = vec3(x * sx, 0, z * sz);
                writefln("vx %d - x: %f z: %f", i-1, x*sx, z*sz);
            }
        }

        auto vb = new GLArrayBuffer();
        vb.bind();
        vb.bufferData(points.length * 3, float.sizeof, cast(void*) points.ptr);
        return vb;
    }

    protected override GLArrayBuffer computeNormalData() 
    {
        int count = px * pz;
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
        int count = px * pz,
            i = 0;
        float sx  = 1.0f / seg_x,
              sy  = 1.0f / seg_z; 

        vec2[] coords = new vec2[px * pz];
        for (int x = 0; x < px; x++) 
            for (int y = 0; y < pz; y++) {
                coords[i++] = vec2(x * sx, y * sy);
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
        ushort[] idx = new ushort[seg_x * seg_z * 6];
        for (int x = 0; x < seg_x; x++) {
            for (int z = 0; z < seg_z; z++) {
                idx[i++] = cast(ushort)( x*pz + z + 1 ); // tl 
                idx[i++] = cast(ushort)( x*pz + z ); // bl
                idx[i++] = cast(ushort)((x+1)*pz + z ); // br

                idx[i++] = cast(ushort)( x*pz + z + 1 ); // tl 
                idx[i++] = cast(ushort)((x+1)*pz + z ); // br
                idx[i++] = cast(ushort)((x+1)*pz + z+1 ); // tr
            }
        }

        auto ib = new GLElementBuffer(GL_UNSIGNED_SHORT);
        ib.bind();
        ib.bufferData(idx.length, ushort.sizeof, cast(void*) idx.ptr);
        return ib;
    }

}
