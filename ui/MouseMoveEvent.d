module ui.MouseMoveEvent;
import gl3n.linalg;

/* Mouse Move struct */
struct MouseMoveEvent
{
    vec2 point;
    vec2 rel;
    bool consumed;

    public this(vec2 point, vec2 rel) 
    {
        this.point = point;
        this.rel = rel;
        this.consumed = false;
    }
}
