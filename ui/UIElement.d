module ui.UIElement;

import gl3n.linalg;
import transform;
import shader;
import ui;

class UIElement
{
    @property Transform2D Transform() { return transform; }
    @property bool Hover() { return is_hover; }

    protected Transform2D transform;
    protected vec2 size;
    protected bool is_hover;
    protected UIElement[] children;

    public this(vec3 position, vec2 size) 
    {
        this.transform = new Transform2D(position.xy);
        this.size = size;
    }

    public void attach(UIElement child) {
        child.Transform.Parent = transform;
        children ~= child;
    }

    /* Returns true if a given point is within the bounds of the element */
    public bool inside(vec2 point) 
    {
        auto position = transform.Position;
        if (point.x > position.x && point.x < position.x + size.x &&
            point.y > position.y && point.y < position.y + size.y) {
            return true;
        }
        return false;
    }

    public void click(MouseClickEvent* event)
    {
        /* Pass on event */
        foreach(child; children) {
            if (child.inside(event.point)) {
                child.click(event);
                if (event.consumed)
                    return;
            }
        }
    }

    public void mouseEnter(MouseMoveEvent* event) {
        is_hover = true;
        foreach(child; children) 
            if (child.inside(event.point) && !child.Hover)
                    child.mouseEnter(event);
    }

    public void mouseLeave(MouseMoveEvent* event) {
        is_hover = false;
        foreach(child; children) 
            if (!child.inside(event.point) && child.Hover)
                child.mouseLeave(event);
    }

    public void drawColored(Shader shader) { 
        foreach(child; children) 
            child.drawColored(shader);
    }

    public void drawTextured(Shader shader) { 
        foreach(child; children) 
            child.drawTextured(shader);
    }
}
