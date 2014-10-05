import gl3n.linalg;

class Transform3D {
}

class Transform2D 
{
    @property vec2 Position() { return position; }
    @property vec2 Position(vec2 value) {
        position = value;
        refresh();
        return position;
    }

    @property vec2 Scale() { return scale; }
    @property vec2 Scale(vec2 value) {
        scale = value;
        refresh();
        return scale;
    }

    @property float ZIndex() { return z_index; }
    @property float ZIndex(float value) {
        z_index = value;
        refresh();
        return z_index;
    }

    @property float Rotation() { return rotation; }
    @property float Rotation(float value) {
        rotation = value;
        refresh();
        return rotation;
    }

    @property mat4 Matrix() { return transform; }

    @property Transform2D Parent() { return parent; }
    @property Transform2D Parent(Transform2D value) { 
        parent = value;
        refresh();
        return parent; 
    }

    vec2 position;
    vec2 scale;
    float z_index;
    float rotation;
    mat4 transform;
    Transform2D parent;

    public this(vec2 position, vec2 scale, float rotation, float z_index) {
        this.position = position;
        this.scale = scale;
        this.rotation = rotation;
        this.z_index = z_index;
        refresh();
    }

    public this(vec2 position) { this(position, vec2(1,1), 0.0, 0.0); }

    /* Recalculate transform matrix */
    protected void refresh() 
    {
        transform = mat4.identity
                        .scale(scale.x, scale.y, 1)
                        .rotatez(rotation * (3.1415f / 180))
                        .translate(position.x, position.y, z_index);

        if (parent !is null) {
            /* Transform hierarchy */
            transform = parent.Matrix * transform;
        }
    }
}

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
