module geometry.GLArrayBuffer;

import derelict.opengl3.gl;
import geometry;

class GLArrayBuffer : GLBuffer
{
    public this() {
        super(GL_ARRAY_BUFFER);
    }
}
