import gl3n.linalg;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;

import geometry;
import shader;

enum MouseButton {
    Left = SDL_BUTTON_LEFT,
    Right = SDL_BUTTON_RIGHT,
}

struct MouseClickEvent {
    MouseButton button;
    vec2 point;
    bool consumed;
}

class UIElement
{
    @property vec2 Size() { return size; }
    @property vec3 Position() { return position; }

    protected vec2 size;
    protected vec3 position;
    protected UIElement[] children;

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
}

class UIManager
{
    UIQuad quad;
    mat4 viewport;
    Shader shader;

    /* Top-level UI elements */
    UIElement[] elements;

    public this() {
        shader = Shader.Create("UIColor");


        viewport = mat4.orthographic(0, 800, 0, 600, -10000, 10000);

        quad = new UIQuad(shader);
        quad.tesselate();
    }

    public void draw() {
        shader.use();
        shader.setMatrix4("Screen", viewport);
        quad.drawColored();

        /* Draw Text */
        /* textShader.use(); */
    }

    protected void onMouseDown(SDL_Event event) 
    {
        auto ui_event = MouseClickEvent(cast(MouseButton) event.button.button, vec2(event.button.x, event.button.y));
        foreach(child; elements) {
            if (ui_event.consumed)
                break;
            if (child.inside(ui_event.point))
                child.click(&ui_event);
        }
    }

    protected void onMouseUp(SDL_Event event) {
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
    vec4 color;
    vec3 position;
    vec2 size;

    Shader shader;
    GLArrayBuffer colorBuffer;

    public this(Shader shader) 
    {
        this.shader = shader;
        color    = vec4(1, 0, 0, 1);
        position = vec3(50, 50, 0);
        size     = vec3(100, 100, 0);
    }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float px = position.x,
               py = position.y,
               pz = position.z,
               width  = size.x,
               height = size.y;

        /* Cast float color to bytes */
        ubyte r = cast(ubyte)( color.x * 255 ),
              g = cast(ubyte)( color.y * 255.0f ),
              b = cast(ubyte)( color.z * 255.0f ),
              a = cast(ubyte)( color.w * 255.0f );

        float[] vertex = [
            px + 0,      py + 0,      pz, 
            px + 0,      py + height, pz, 
            px + width,  py + height, pz, 

            px + 0,      py + 0,      pz, 
            px + height, py + 0,      pz, 
            px + width,  py + height, pz, 
        ];
        ubyte[] colors = [
            r, g, b, a, r, g, b, a, r, g, b, a,
            r, g, b, a, r, g, b, a, r, g, b, a,
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(vertex.length, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        colorBuffer = new GLArrayBuffer();
        colorBuffer.bufferData(colors.length, ubyte.sizeof, cast(void*) colors.ptr);
        glVertexAttribPointer(1, 4, GL_UNSIGNED_BYTE, GL_TRUE,  0, null); // Color

        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
    }

    public void drawColored() 
    {
        this.bind();
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    protected override GLArrayBuffer computeVertexData() { return null; }
    protected override GLArrayBuffer computeTexcoordData() { return null; }
    protected override GLArrayBuffer computeNormalData() { return null; }
    protected override GLElementBuffer computeElementData() { return null; }
}
