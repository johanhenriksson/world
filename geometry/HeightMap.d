module geometry.HeightMap;

import std.math;
import std.stdio;
import gl3n.linalg;
import derelict.sdl2.sdl;
import geometry;

/* Extract data structure */
class HeightMapData
{
    protected float[][] height;
    protected float sizeX;
    protected float sizeZ;
}

class HeightMap : Quad
{
    protected float[][] height;

    public this(int x, int z) {
        super(x, z, x, z);
        vertexBuffer = new GLArrayBuffer();
        height = new float[][](px,pz);
        for(int i = 0; i < px; i++)
            for (int j = 0; j < pz; j++)
                height[i][j] = sin(i / 10.0f);
    }

    public void click(ubyte button, vec3 point) 
    {
        int x = cast(int)round(point.x);
        int z = cast(int)round(point.z);
        if (x > size_x || z > size_z)
            return;

        auto offset = 0.0f;
        if (button == SDL_BUTTON_LEFT)
            offset = 0.2f;
        else
            offset = -0.2f;

        height[x][z] += offset;
        computeVertexData();

        writefln("x: %d, z: %d", x, z);
    }

    public float heightAt(int x, int z) {
        return height[x][z];
    }

    protected override GLArrayBuffer computeVertexData() 
    {
        int i = 0;
        float sx = size_x / seg_x,
              sz = size_z / seg_z;

        vec3[] points = new vec3[px * pz];
        for (int x = 0; x < px; x++) 
            for (int z = 0; z < pz; z++) {
                // Lookup height
                points[i++] = vec3(x * sx, heightAt(x,z), z * sz);
                writefln("vx %d - x: %f z: %f", i-1, x*sx, z*sz);
            }

        vertexBuffer.bind();
        vertexBuffer.bufferData(points.length * 3, float.sizeof, cast(void*) points.ptr);
        return vertexBuffer;
    }
}
