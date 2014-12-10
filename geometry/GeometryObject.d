module geometry.GeometryObject;

import derelict.opengl3.gl;
import geometry;

abstract class GeometryObject : GLArray
{
    protected GLArrayBuffer vertexBuffer;
    protected GLArrayBuffer normalBuffer;
    protected GLArrayBuffer texcoordBuffer;
    protected GLElementBuffer indexBuffer;

    /* Generate & upload geometry */
    public override void tesselate() 
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
