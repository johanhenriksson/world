module engine.Transform;

import gl3n.linalg;
import engine;

class Transform : Component
{
    @property vec3 Position() { return position; }
    @property quat Rotation() { return rotation; }
    @property vec3 Angle() { return angle; }
    @property vec3 AngleRadians() { return angle * (3.141592f / 180); }

    @property mat4 ModelMatrix() { return transform; }

    private mat4 transform;

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

    }

    public override void tick(float dt, float time) 
    {
        if (changed)
            refresh();
    }

    protected void refresh() 
    {
        vec3 rot = AngleRadians;
        rotation  = quat.euler_rotation(rot.y, rot.x, rot.z);
        transform = mat4.scaling(scale.x, scale.y, scale.z) * 
                    rotation.to_matrix!(4,4)() *
                    mat4.translation(position.x, position.y, position.z);
        forward = vec3(
            cos(rot.y) * cos(rot.x),
            sin(rot.x),
            sin(rot.y) * cos(rot.x)
        );
        right = forward.cross(vec3(0,1,0));
        up = right.cross(forward);
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
}
