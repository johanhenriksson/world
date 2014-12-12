module engine.Camera;

import derelict.opengl3.gl;
import gl3n.linalg;

class Camera
{
    protected float fov;
    protected float aspectRatio;
    protected int width;
    protected int height;

    protected mat4 projection;
    protected mat4 view;

    protected vec3 position;
    protected vec3 up;
    protected vec3 forward;
    protected vec3 right;
    protected float pitch;
    protected float yaw;

    @property vec3 Position() { return this.position; }
    @property mat4 ViewMatrix() { return this.view; }
    @property mat4 ProjectionMatrix() { return this.view; }

    public this(int width, int height) 
    {
        this.width = width;
        this.height = height;
        position = vec3(4,5,4);
        view = IsometricView(position);
        projection = OrthograpicProjection(24, 8, -100, 100);
        aspectRatio = cast(float)width / height;
    }

    protected void refresh() {
        /* Calculate current rotaiton */
        vec3 euler = vec3(
            cos(this.yaw) * cos(this.pitch),
            sin(this.pitch),
            sin(this.yaw) * cos(this.pitch)
        );
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

            mat4 pvi = projection * view;
            pvi.invert(); 
            vec4 world = pvi * point;

            /* World space coord */
            return vec3(world.x / world.w, world.y / world.w, world.z / world.w);
    }

    /* Some static helpers */

    public static mat4 IsometricView(vec3 position) {
        return mat4.identity
                   .rotatey((90 + 45) * 3.1415f / 180)
                   .rotatex(35 * 3.1415f / 180)
                   .translate(position.x, position.y, position.z);
    }

    public static mat4 OrthograpicProjection(float width, float height, float near, float far) {
        return mat4.orthographic(0, width, 0, height, near, far);
    }
}
