module engine.Transform;

import gl3n.linalg;
import engine;

class Transform : Component
{
    @property vec3 Position() { return position; }
    @property quat Rotation() { return rotation; }
    @property vec3 Right()    { return right; }
    @property vec3 Forward()  { return forward; }
    @property vec3 Up()       { return up; }
    @property vec3 Angle()    { return angle; }

    @property vec3 AngleRadians() { return angle * (PI / 180); }
    @property mat4 ModelMatrix()  { return transform; }
    @property mat4 InverseModel() { return inverse; }

    private mat4 transform;
    private mat4 inverse;

    private vec3 forward;
    private vec3 right;
    private vec3 up;
    private vec3 position;
    private vec3 scale;
    private vec3 angle;
    private quat rotation;
    private bool changed;

    public this(Entity entity) 
    {
        super(entity);
        position = vec3(0,0,0);
        angle    = vec3(0,0,0);
        scale    = vec3(1,1,1);
        rotation = quat.identity;
        changed  = true;
        refresh();
    }

    public override void tick(float dt, float time) 
    {
        if (changed)
            refresh();
    }

    protected void refresh() 
    {
        vec3 rot = AngleRadians;

        /* Refresh transform */
        rotation  = quat.euler_rotation(rot.y, rot.z, rot.x); 
        transform = mat4.scaling(scale.x, scale.y, scale.z) * 
                    rotation.to_matrix!(4,4)() *
                    mat4.translation(position.x, position.y, position.z);

        /* Read direction vectors */
        right   =  vec3(transform[0][0], transform[1][0], transform[2][0]);
        up      =  vec3(transform[0][1], transform[1][1], transform[2][1]);
        forward = -vec3(transform[0][2], transform[1][2], transform[2][2]);

        inverse = transform.inverse();
        changed = false;
    }

    @property vec3 Position(vec3 position) {
        this.position = position;
        changed = true;
        refresh();
        return position;
    }

    @property vec3 Scale(vec3 scale) {
        this.scale = scale;
        changed = true;
        refresh();
        return scale;
    }

    @property vec3 Angle(vec3 angle) {
        this.angle = angle;
        changed = true;
        refresh();
        return angle;
    }

    /* Transformations */
    public vec3 TransformPoint(vec3 point) { return (transform * vec4(point, 1.0f)).xyz; }
    public vec3 TransformDirection(vec3 direction) { return (transform * vec4(direction, 0.0f)).xyz; }
    public vec3 InverseTransformPoint(vec3 point) { return (inverse * vec4(point, 1.0f)).xyz; }
    public vec3 InverseTransformDirection(vec3 direction) { return (inverse * vec4(direction, 0.0f)).xyz; }
}
