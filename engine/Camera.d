module engine.Camera;

import derelict.opengl3.gl;
import gl3n.linalg;
import engine;

class Camera : Component
{
    protected float fov = 50.0f;
    protected float aspectRatio;
    protected float near = 0.1f;
    protected float far  = 100.0f;
    protected int width;
    protected int height;

    protected mat4 projection;

    @property mat4 ViewMatrix() { return entity.transform.ModelMatrix; }
    @property mat4 ProjectionMatrix() { return this.projection; }

    public this(Entity entity, int width, int height) 
    {
        super(entity);
        this.width = width;
        this.height = height;

        projection = mat4.perspective(width, height, fov, near, far);
        aspectRatio = cast(float)width / height;
    }

    public vec3 unproject(int x, int y)
    {
        float depth = 0.0f;
        glReadPixels(x, height - y - 1, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, cast(void*) &depth);
        /* Clip space coord */
        auto point = vec4(
            (cast(float)x / width) * 2 - 1, 
            (1 - cast(float)y / height) * 2 - 1, 
            depth * 2 - 1, 
            1);

        mat4 pvi = projection * ViewMatrix;
        pvi.invert(); 
        vec4 world = pvi * point;

        /* World space coord */
        return vec3(world.x / world.w, world.y / world.w, world.z / world.w);
    }
}
