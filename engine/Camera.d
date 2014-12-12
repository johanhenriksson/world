module engine.Camera;

import derelict.opengl3.gl;
import gl3n.linalg;
import engine;

class Camera : Component
{
    protected float fov;
    protected float aspectRatio;
    protected int width;
    protected int height;

    protected mat4 projection;

    protected vec3 up;
    protected vec3 forward;
    protected vec3 right;
    protected float pitch;
    protected float yaw;

    @property mat4 ViewMatrix() { return entity.transform.ModelMatrix; }
    @property mat4 ProjectionMatrix() { return this.projection; }

    public this(Entity entity, int width, int height) 
    {
        super(entity);
        this.width = width;
        this.height = height;
        this.up = vec3(0,1,0);

        projection = OrthograpicProjection(24, 8, -100, 100);
        IsometricView();
        aspectRatio = cast(float)width / height;
    }

    protected void refresh() {
        /* Calculate current rotaiton */
        vec3 euler = vec3(
            cos(this.yaw) * cos(this.pitch),
            sin(this.pitch),
            sin(this.yaw) * cos(this.pitch)
        );

        //mat4.look_at(this.position, lookTarget, this.up);
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

    /* Some static helpers */

    public void IsometricView() {
        transform.Angle = vec3(35, 135, 0);
    }

    public static mat4 OrthograpicProjection(float width, float height, float near, float far) {
        return mat4.orthographic(0, width, 0, height, near, far);
    }
}
