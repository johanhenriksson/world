module geometry.GLBuffer;

import std.stdio;
import derelict.opengl3.gl;

class GLBuffer
{
    protected uint id;
    protected uint type;
    protected uint storageType;
    protected ulong elements;

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
        writefln("Buffering %d elements (each: %d, total %d)", 
            elements,
            size,
            elements * size
        );
        this.bind();
        glBufferData(this.type, elements * size, ptr, this.storageType);
    }
}
