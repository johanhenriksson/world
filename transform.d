import gl3n.linalg;

class Transform 
{
    @property mat4 Model()    { return transform; }
    @property vec3 Position() { return position; }
    @property vec3 Scale()    { return scale; }

    @property vec3 Scale(vec3 value) {
        scale = value;
        recalculate();
        return scale;
    }

    @property vec3 Position(vec3 value) {
        position = value;
        recalculate();
        return position;
    }

    @property vec3 Rotation(vec3 value) {
        rotation = value;
        recalculate();
        return rotation;
    }

    @property vec3 Angle() {
        return rotation * (180.0f / 3.14159f);
    }

    @property vec3 Angle(vec3 value) {
        rotation = value * (3.14159f / 180.0f);
        recalculate();
        return value;
    }

    private mat4 transform;
    private vec3 position;
    private vec3 rotation;
    private vec3 scale;
    private quat rot;

    private Transform parent;
    private Transform[] nodes;

    public this() {
        position = vec3(0,0,0);
        rotation = vec3(0,0,0);
        scale    = vec3(1,1,1);
        rot      = quat.identity;
        recalculate();
    }

    public void RotateX(float degrees) {
        rot.rotatex(degrees * 3.1415f / 180.0f);
        recalculate();
    }

    public void RotateY(float degrees) {
        rot.rotatey(degrees * 3.1415f / 180.0f);
        recalculate();
    }

    private void recalculate() 
    {
        auto mat = mat4.scaling(scale.x, scale.y, scale.z); // Scale
        mat = rot.to_matrix!(4,4) * mat; // Rotate 
        mat = mat.translate(position.x, position.y, position.z); // Translate

        this.transform = mat;
    }
}
