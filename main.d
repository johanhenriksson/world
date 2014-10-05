/* External */
import std.stdio;
import std.string;
import gl3n.math;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import derelict.opengl3.gl;
import derelict.util.exception;

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

    public this(float width, float height) {
        this.size = vec2(width, height);
        this.aspect = width / height;
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
        glClearColor(0.2, 0.2, 0.2, 1);

        glPolygonMode(GL_BACK, GL_LINE); /* Draw backfacing as wireframe */

        TTF_Init();
    }
    
    public mat4 IsometricPerspective(float x, float y, float z) 
    {
        return mat4.identity
                   .rotatey(45 * 3.1415f / 180)
                   .rotatex(35 * 3.1415f / 180)
                   .translate(x, y, z);
    }

    public void run() 
    {
        auto cube = new IsoCube();
        cube.tesselate();

        auto plane = new Quad(5,5);
        plane.tesselate();

        auto model = mat4.identity;
        auto model2 = mat4.translation(1,0,0);
        auto model3 = mat4.translation(0,-1,0);


        vec3 position = vec3(4, 3, 4);
        /* isometric view */
        auto view = IsometricPerspective(position.x, position.y, position.z);

        /* Compile shader */
        auto program = Shader.Create("basic");
        program.use();

        /* MVP */
        mat4 projection = mat4.orthographic(0, 8, 0, 6, -10000, 10000);
        program.setMatrix4("Projection", projection);

        auto ui = new UIManager(cast(int)size.x, cast(int)size.y);

        float r = 45.0f;
        bool mouse = false;

        uint lastTime = SDL_GetTicks();

        writeln(glGetError());

        auto material = new Material(program);
        material.Diffuse = new Texture("rock.jpg");

        writeln("about to run loop");
        writeln(glGetError());

        auto run = true;
        while(run) 
        {
            uint time = SDL_GetTicks();
            float dt = (time - lastTime) / 1000.0f;
            lastTime = time;

            SDL_Event event;
            while (SDL_PollEvent(&event)) {
                ui.processEvent(event);
                switch(event.type) {
                    case SDL_QUIT:
                        run = false;
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        mouse = true;
                        break;
                    case SDL_MOUSEBUTTONUP:
                        mouse = false;
                        break;
                    case SDL_MOUSEMOTION:
                        if (mouse) {
                            auto p = vec3(event.motion.xrel, -event.motion.yrel, 0);
                            position = position + p * 5 * dt;
                            view = IsometricPerspective(position.x, position.y, position.z);
                        }
                        break;
                    default: 
                        break;
                }
            }

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            material.use();
            program.setMatrix4("View", view);
            //program.setVec3("CameraPos", position);
            program.setVec3("LightPos", vec3(-1,3,-1));

            //plane.draw();

            program.setMatrix4("Model", model);
            cube.draw();

            program.setMatrix4("Model", model2);
            cube.draw();

            program.setMatrix4("Model", model3);
            cube.draw();

            ui.draw();

            /* Swap buffers */
            SDL_GL_SwapWindow(window);
        }
    }
}

void main() 
{
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

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    auto world = new World(800, 600);
    world.init();
    world.run();

    SDL_Quit();
}
