module geometry.GLArray;

import derelict.opengl3.gl;
import geometry;

abstract class GLArray 
{
    private uint vao;

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

    public abstract void tesselate();
}
