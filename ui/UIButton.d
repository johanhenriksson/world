module ui.UIButton;

import std.stdio;
import gl3n.linalg;
import derelict.opengl3.gl;
import shader;
import ui;

class UIButton : UIElement
{
    @property vec4 Color() { return background.Color; } 
    @property vec4 Color(vec4 value) { return background.Color = value; }

    protected vec4 color = vec4(0.5f, 38.0f / 255, 38.0f / 255, 1);
    protected vec4 hoverColor = vec4(1.0, 76.0f / 255, 76.0f / 255, 1);

    protected UIQuad background;
    protected UIText label;

    public this(Font font, string text, int x, int y, int width, int height) {
        super(vec3(x,y,0), vec2(width, height));

        background = new UIQuad(this.size, color);
        background.tesselate();

        label = new UIText(vec2(10,10), "Click Me", vec4(1,1,1,1), font);

        attach(label);
    }

    public override void drawColored(Shader shader) {
        shader.setMatrix4("Transform", transform.Matrix);
        background.drawColored(shader);
    }

    public override void click(MouseClickEvent* event) 
    {
        /* Buttons arent really supposed to have children */
        super.click(event);
        if (event.consumed)
            return;

        writeln("button clicked!");
        background.Color = vec4(0,0,1,1);
    }

    public override void mouseEnter(MouseMoveEvent* event) {
        background.Color = hoverColor; 
        super.mouseEnter(event);
    }

    public override void mouseLeave(MouseMoveEvent* event) {
        background.Color = color;
        super.mouseLeave(event);
    }
}
