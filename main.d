/* External */
import std.stdio;
import std.string;
import std.math;
import gl3n.math;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import derelict.opengl3.gl;
import derelict.util.exception;

import engine;
import shader;
import geometry;
import material;
import transform;
import ui;

pragma(lib, "libSDL2-2.0.so");


class World
{
    private SDL_Window* window;
    private SDL_GLContext context;
    private vec2 size;
    private float aspect;
    private float targetFps;
    private float targetFrameTime;

    public this(float width, float height) {
        this.size = vec2(width, height);
        this.aspect = width / height;
        this.targetFps = 60.0f;
        this.targetFrameTime = 1 / targetFps;
    }

    public void init() 
    {
        /* Create Window */
        window = SDL_CreateWindow(
            "SDL2 window",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            cast(int) size.x, cast(int) size.y,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN
        );
        if (!window)
            throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));

        /* Create OpenGL Context */
        context = SDL_GL_CreateContext(window);
        if (!context)
            throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));

        DerelictGL.reload();

        /* OpenGL Settings */
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        //glDepthFunc(GL_LEQUAL);
        glClearColor(0.2, 0.2, 0.2, 1);


        TTF_Init();
    }
    
    public mat4 IsometricPerspective(float x, float y, float z) 
    {
        return mat4.identity
                   .rotatey((90 + 45) * 3.1415f / 180)
                   .rotatex(35 * 3.1415f / 180)
                   .translate(x,y,z);
    }

    public void run() 
    {
        auto plane = new HeightMap(15,15);
        plane.tesselate();

        auto model = mat4.identity;

        vec3 position = vec3(4, 5, 4);
        /* isometric view */
        auto view = IsometricPerspective(position.x, position.y, position.z);

        /* Compile shader */
        auto program = Shader.Create("basic");
        program.use();

        /* MVP */
        mat4 projection = mat4.orthographic(0, 24, 0, 18, -100, 100);
        program.setMatrix4("Projection", projection);

        auto ui = new UIManager(cast(int)size.x, cast(int)size.y);

        writeln("UI manager created");

        float r = 45.0f;
        bool mouse = false;

        uint lastTime = SDL_GetTicks();

        writeln(glGetError());

        auto material = new Material(program);
        writeln("setting diffuse?");
        material.Diffuse = new Texture("assets/rock.jpg");

        writeln("about to run loop");
        writeln(glGetError());

        auto run = true;
        while(run) 
        {
            uint time = SDL_GetTicks();
            float dt = (time - lastTime) / 1000.0f;
            lastTime = time;

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            program.use();
            material.use();
            program.setMatrix4("View", view);
            program.setMatrix4("Model", model);
            program.setVec3("CameraPos", position);
            program.setVec3("LightPos", vec3(7,7,7));

            plane.draw();

            SDL_Event event;
            while (SDL_PollEvent(&event)) {
                ui.processEvent(event);
                switch(event.type) {
                    case SDL_QUIT:
                        run = false;
                        break;
                    case SDL_MOUSEBUTTONUP:
                        mouse = false;
                        break;
                    case SDL_MOUSEMOTION:
                        if (mouse) {
                            auto p = vec3(event.motion.xrel, -event.motion.yrel, 0);
                            position = position + p * 2 * dt;
                            view = IsometricPerspective(position.x, position.y, position.z);
                        }
                        break;
                    case SDL_MOUSEWHEEL:
                            position.z -= event.wheel.y;
                            view = IsometricPerspective(position.x, position.y, position.z);
                            break;
                    default: 
                        break;
                }
            }

            ui.draw();

            /* Swap buffers */
            SDL_GL_SwapWindow(window);

            /* Delay to target fps */
            float delay = targetFrameTime - dt;
            if (delay > 0)
                SDL_Delay(cast(uint)( delay * 1000 ));
        }
    }
}

static Font UIFONT;

void main() 
{
    writeln("vec3 size: %d", vec3.sizeof);

    DerelictGL.load();
    DerelictSDL2.load();
    DerelictSDL2Image.load();
    try {
        DerelictSDL2ttf.load();
    }
    catch(SymbolLoadException ex) {
        writefln("Cannot find symbol %s", ex.msg); 
    }

    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    /*
    auto world = new World(1200, 900);
    world.init();
    world.run();
    */
    Window wnd = new Window("hello world", 800, 600);
    wnd.show();

    float targetFrameTime = 1.0f / 60;

    uint start_time = SDL_GetTicks();
    uint last_time = start_time - 1;
    while(wnd.isOpen) 
    {
        /* Frame time calculations */
        uint time = SDL_GetTicks();
        float elapsed = (time - start_time) / 1000.0f;
        float dt = (time - last_time) / 1000.0f;
        last_time = time;

        wnd.tick(dt, elapsed);
        wnd.draw();

        /* Delay to target frame rate */
        float delay = targetFrameTime - dt;
        if (delay > 0.0f)
            SDL_Delay(cast(uint)( delay * 1000 ));
    }

    /* Quit */

    SDL_Quit();
}
