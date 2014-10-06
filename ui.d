import std.stdio;
import std.string;
import gl3n.linalg;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;

import geometry;
import transform;
import shader;
import material;

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
    vec2 rel;
    bool consumed;

    public this(vec2 point, vec2 rel) 
    {
        this.point = point;
        this.rel = rel;
        this.consumed = false;
    }
}

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

class UIButton : UIElement
{
    @property vec4 Color() { return background.Color; } 
    @property vec4 Color(vec4 value) { return background.Color = value; }

    protected vec4 color = vec4(0.5f, 38.0f / 255, 38.0f / 255, 1);
    protected vec4 hoverColor = vec4(1.0, 76.0f / 255, 76.0f / 255, 1);

    protected UIQuad background;
    protected UIText label;

    public this(string text, int x, int y, int width, int height) {
        super(vec3(x,y,0), vec2(width, height));

        background = new UIQuad(this.size, color);
        background.tesselate();

        if (UIFONT is null)
            throw new Exception("No ui font");

        label = new UIText(vec2(10,10), "Hello World", vec4(1,1,1,1), UIFONT);

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

class UIText : UIElement
{
    @property string Text() { return text; }
    @property vec4 Color() { return color; }
    @property Font TextFont() { return font; }

    @property string Text(string value) {
        text = value;
        refresh();
        return text;
    }

    @property vec4 Color(vec4 value) {
        color = value;
        refresh();
        return color;
    }

    private UITexture texture;
    private Font font;
    private string text;
    private vec4 color;

    public this(vec2 position, string text, vec4 color, Font font) 
    {
        super(vec3(position.x, position.y, 0), vec2(0,0));
        this.font = font;
        this.text = text;
        this.color = color;

        auto surface   = font.Render(text, color);
        auto gltexture = new Texture(surface);
        this.texture   = new UITexture(gltexture);
        this.texture.tesselate();
    }

    protected void refresh() 
    {
        /* Ugly as fuck */
        auto surface = UIFONT.Render(text, color);
        texture.GLTexture.loadFromSurface(surface);
        size = vec2(texture.GLTexture.Width, texture.GLTexture.Height);
    }

    public override void drawTextured(Shader shader) {
        shader.setMatrix4("Transform", transform.Matrix);
        texture.drawTextured(shader);
    }
}

static Font UIFONT;

class UIManager
{
    UIQuad quad;
    mat4 viewport;
    Shader colorShader;
    Shader textureShader;

    int width;
    int height;

    /* Top-level UI elements */
    UIElement[] elements;
    UIButton button;

    public this(int width, int height) 
    {
        UIFONT = new Font("ubuntu_mono.ttf", 12);

        this.width = width;
        this.height = height;
        colorShader = Shader.Create("UIColor");
        textureShader = Shader.Create("UITexture");

        viewport = mat4.orthographic(0, width, 0, height, -10000, 10000);

        button = new UIButton("hello", 100, 100, 140, 40);
        elements = [ button ];
    }

    public void draw() 
    {
        glClear(GL_DEPTH_BUFFER_BIT);

        /* Colored */
        colorShader.use();
        colorShader.setMatrix4("Screen", viewport);
        foreach(child; elements) 
            child.drawColored(colorShader);

        glClear(GL_DEPTH_BUFFER_BIT);

        /* Draw Text */
        textureShader.use(); 
        textureShader.setMatrix4("Screen", viewport);
        foreach(child; elements) 
            child.drawTextured(textureShader);
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

    protected void onMouseMove(SDL_Event event) 
    {
        auto ui_event = MouseMoveEvent(
            vec2(event.motion.x, height - event.motion.y),
            vec2(event.motion.xrel, -event.motion.yrel)
        );

        /* Update hover state */
        foreach(child; elements) 
        {
            if (child.inside(ui_event.point)) {
                if (!child.Hover)
                    child.mouseEnter(&ui_event);
            }
            else {
                if (child.Hover) 
                    child.mouseLeave(&ui_event);
            }
        }
    }

    public void processEvent(SDL_Event event) 
    {
        /* Handle Mouse & Keyboard GUI Input */
        switch(event.type) 
        {
            case SDL_MOUSEBUTTONDOWN: onMouseDown(event); break;
            case SDL_MOUSEBUTTONUP: onMouseUp(event); break;
            case SDL_MOUSEMOTION: onMouseMove(event); break;
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

class UITexture : GLArray
{
    @property Texture GLTexture() { return texture; }

    private Texture texture;
    private vec2 size;

    public this(Texture texture, int width, int height) {
        this.texture = texture;
        this.size = vec2(width, height);
    }

    public void replace(Texture newTexture) {
        texture = newTexture;
    }

    public this(Texture texture) { this(texture, texture.Width, texture.Height); }

    public override void tesselate() 
    {
        /* Cast dimensions to ushort */
        float width  = size.x,
              height = size.y;

        float[] vertex = [
            0,      height, 0, 
            0,      0,      0, 
            width,  height, 0, 

            0,      0,      0, 
            width,  0,      0, 
            width,  height, 0, 
        ];

        float[] texcoord = [
            0, 0,
            0, 1,
            1, 0,

            0, 1,
            1, 1,
            1, 0,
        ];

        this.bind();

        vertexBuffer = new GLArrayBuffer();
        vertexBuffer.bufferData(vertex.length, float.sizeof, cast(void*) vertex.ptr);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null); // Position

        texcoordBuffer = new GLArrayBuffer();
        texcoordBuffer.bufferData(texcoord.length, float.sizeof, cast(void*) texcoord.ptr);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, null); // Position

        glEnableVertexAttribArray(0);
        glEnableVertexAttribArray(1);
    }

    public void drawTextured(Shader shader) 
    {
        this.bind();

        glActiveTexture(GL_TEXTURE0);
        texture.bind();
        shader.setInt("Texture", 0);

        glDrawArrays(GL_TRIANGLES, 0, 6);
    }

    protected override GLArrayBuffer computeVertexData() { return null; }
    protected override GLArrayBuffer computeTexcoordData() { return null; }
    protected override GLArrayBuffer computeNormalData() { return null; }
    protected override GLElementBuffer computeElementData() { return null; }
}
