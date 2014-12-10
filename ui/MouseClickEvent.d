module ui.MouseClickEvent;
import ui;
import gl3n.linalg;

/* Click event struct */
struct MouseClickEvent 
{
    MouseButton button;
    vec2 point;
    bool down;
    bool consumed;

    this(MouseButton button, vec2 point, bool down) 
    {
        this.button   = button;
        this.point    = point;
        this.down     = down;
        this.consumed = false;
    }
}
