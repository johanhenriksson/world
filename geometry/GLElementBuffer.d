module geometry.GLElementBuffer;

import derelict.opengl3.gl;
import geometry;

class GLElementBuffer : GLBuffer
{
    protected uint primitive;
    protected uint dataType;

    public this(uint datatype) {
        super(GL_ELEMENT_ARRAY_BUFFER);
        this.primitive = GL_TRIANGLES;
        this.dataType = datatype;
    }

    public void draw() {
        glDrawElements(this.primitive, cast(int) this.elements, this.dataType, null);
    }
}
