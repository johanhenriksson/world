module engine.Window;

import std.stdio;
import std.conv;
import std.string;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import derelict.opengl3.gl;
import engine;
import input;
import ui;

/** Wraps the SDL window and GL context */
class Window
{
    @property int Width() { return this.width; }
    @property int Height() { return this.height; }
    @property string Title() { return this.title; }
    @property bool isOpen() { return this.open; }

    private bool open;
    private string title;
    private int width;
    private int height;
    private SDL_Window* window;
    private SDL_GLContext context;
    private Viewport viewport;
    private UIManager uim;

    private bool mouse;

    public this(string title, int width, int height) 
    {
        this.title = title;
        this.width = width;
        this.height = height;
        this.open = false;
    }

    public void show() 
    {
        if (open)
            throw new Exception("Window is already open");

        /* Create SDL window */
        this.window = this.createWindow();

        /* Create OpenGL Context */
        this.context = SDL_GL_CreateContext(this.window);
        if (!this.context)
            throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));

        /* Required after context creation. Not sure why */
        DerelictGL.reload();

        this.initGL();

        this.open = true;

        auto camObj = new Entity();
        camObj.transform.Position = vec3(0, 2, 0);
        camObj.transform.Angle    = vec3(0, -90, 0);
        auto camera = new Camera(camObj, width, height);
        camObj.attach(camera);

        uim = new UIManager(width, height);
        viewport = new Viewport(camera, new Scene());
    }

    public void close() 
    {
        this.open = false;
        SDL_DestroyWindow(this.window);
    }

    protected SDL_Window* createWindow() 
    {
        SDL_Window* window = SDL_CreateWindow(
            this.title.toStringz(),
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            this.width, this.height,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN
        );
        if (!window)
            throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));
        return window;
    }

    protected void initGL() 
    {
        /* OpenGL Settings */
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //glDepthFunc(GL_LEQUAL);
        glClearColor(0.2, 0.2, 0.2, 1);
    }

    public void tick(float dt, float time) 
    {
        /* Poll SDL events */
        SDL_Event event;
        while (SDL_PollEvent(&event)) 
        {
            uim.processEvent(event);
            switch(event.type) 
            {
                case SDL_QUIT:
                    this.close();
                    break;
                case SDL_MOUSEBUTTONUP:
                    mouse = false;
                    break;
                case SDL_MOUSEBUTTONDOWN:
                    mouse = true;
                    break;
                case SDL_MOUSEMOTION:
                    if (mouse) {
                        auto p = 10 * dt * vec3(event.motion.xrel, event.motion.yrel, 0);
                        vec3 angle = viewport.camera.transform.Angle;
                        angle.x -= p.y; // up-down: pitch
                        angle.y -= p.x; // left-right: yaw
                        if (angle.x > 89)
                            angle.x = 89;
                        if (angle.x < -89)
                            angle.x = -89;
                        if (angle.y > 180)
                            angle.y -= 360;
                        if (angle.y < -180)
                            angle.y += 360;
                        viewport.camera.transform.Angle = angle;
                    }
                    break;

                case SDL_KEYUP:
                case SDL_KEYDOWN:
                case SDL_TEXTINPUT:
                    Keyboard.handleEvent(&event);
                    break;

                default: break;
            }
        }

        /* Update scene */
        viewport.tick(dt, time);
    }

    public void draw()
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        /* Draw viewport */
        viewport.draw();

        /* Draw user interface */
        uim.draw();

        /* Swap buffers */
        SDL_GL_SwapWindow(window);
    }
}
