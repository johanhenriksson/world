module ui.UIManager;

import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.opengl3.gl;
import shader;
import ui;

class UIManager
{
    Font uifont;
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
        uifont = new Font("ubuntu_mono.ttf", 12);

        this.width = width;
        this.height = height;
        colorShader = Shader.Create("UIColor");
        textureShader = Shader.Create("UITexture");

        viewport = mat4.orthographic(0, width, 0, height, -10000, 10000);

        button = new UIButton(uifont, "hello", 100, 100, 140, 40);
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
