import std.stdio;
import std.string;
import gl3n.linalg;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;

import geometry;
import shader;

enum MouseButton {
    Left = SDL_BUTTON_LEFT,
    Right = SDL_BUTTON_RIGHT,
}

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

/* Mouse Move struct */
struct MouseMoveEvent
{
    vec2 point;
    bool consumed;

    public this(vec2 point) 
    {
        this.point = point;
        this.consumed = false;
    }
}

class UIElement
{
    @property vec2 Size() { return size; }
    @property vec3 Position() { return position; }

    @property vec2 Size(vec2 value) { return size = value; }
    @property vec3 Position(vec3 value) {
        position = value;
        refresh();
        return position;
    }

    protected vec2 size;
    protected vec3 position;
    protected mat4 transform;
    protected UIElement[] children;

    public this(vec3 position, vec2 size) 
    {
        this.position = position;
        this.size = size;
        refresh();
    }

    public void refresh() {
        transform = mat4.translation(position.x, position.y, position.z);
    }

    /* Returns true if a given point is within the bounds of the element */
    public bool inside(vec2 point) 
    {
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

    public void drawColored(Shader shader) { }
    public void drawText(Shader shader) { }
}

class UIButton : UIElement
{
    protected UIQuad background;
    protected vec4 color = vec4(0.75, 0.2, 0.2, 1.0);

    public this(string text, int x, int y, int width, int height) {
        super(vec3(x,y,0), vec2(width, height));

        background = new UIQuad(this.size, this.color);
        background.tesselate();
    }

    public override void drawColored(Shader shader) {
        shader.setMatrix4("Transform", transform);
        background.drawColored(shader);
    }

    public override void click(MouseClickEvent* event) {
        writeln("button clicked!");
        background.Color = vec4(0,0,1,1);
    }
}

class UIManager
{
    UIQuad quad;
    mat4 viewport;
    Shader shader;

    int width;
    int height;

    /* Top-level UI elements */
    UIElement[] elements;
    UIButton button;

    public this(int width, int height) 
    {
        this.width = width;
        this.height = height;
        shader = Shader.Create("UIColor");
        viewport = mat4.orthographic(0, width, 0, height, -10000, 10000);

        button = new UIButton("hello", 100, 100, 200, 75);
        elements = [ button ];
    }

    public void draw() 
    {
        /* Colored */
        shader.use();
        shader.setMatrix4("Screen", viewport);

        foreach(child; elements) {
            child.drawColored(shader);
        }

        /* Draw Text */
        /* textShader.use(); */
    }

    protected void onMouseDown(SDL_Event event) 
    {
        auto ui_event = MouseClickEvent(
            cast(MouseButton) event.button.button, 
            vec2(event.button.x, this.height - event.button.y),
            true
        );
        foreach(child; elements) {
            if (ui_event.consumed)
                break;
            /*
            if (child.inside(ui_event.point))
                child.click(&ui_event);
            */
        }
    }

    protected void onMouseUp(SDL_Event event) 
    {
        auto ui_event = MouseClickEvent(
            cast(MouseButton) event.button.button, 
            vec2(event.button.x, this.height - event.button.y),
            false
        );
        foreach(child; elements) {
            if (ui_event.consumed)
                break;
            if (child.inside(ui_event.point))
                child.click(&ui_event);
        }
    }

    public void processEvent(SDL_Event event) 
    {
        /* Handle Mouse & Keyboard GUI Input */
        switch(event.type) 
        {
            case SDL_MOUSEBUTTONDOWN: onMouseDown(event); break;
            case SDL_MOUSEBUTTONUP: onMouseUp(event); break;
            case SDL_MOUSEMOTION:
                break;
            default: 
                break;
        }
    }
}

class UIQuad : GLArray
{
    @property vec4 Color() { return color; }
    @property vec2 Size()  { return size; }

    @property vec4 Color(vec4 value) { return color = value; }
    @property vec2 Size(vec2 value)  { return size  = value; }

    vec4 color;
    vec2 size;

    public this(vec2 size, vec4 color)
    {
        this.color = color;
        this.size = size;
    }

    public ~this() {
        delete vertexBuffer;
    }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float width  = size.x,
              height = size.y;

        float[] vertex = [
            0,      0,      0, 
            0,      height, 0, 
            width,  height, 0, 

            0,      0,      0, 
            width,  0,      0, 
            width,  height, 0, 
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(vertex.length, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        glEnableVertexAttribArray(0);
    }

    public void drawColored(Shader shader) 
    {
        shader.setVec4("Color", this.color);
        this.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    protected override GLArrayBuffer computeVertexData() { return null; }
    protected override GLArrayBuffer computeTexcoordData() { return null; }
    protected override GLArrayBuffer computeNormalData() { return null; }
    protected override GLElementBuffer computeElementData() { return null; }
}
