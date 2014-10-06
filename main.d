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

vec3 Unproject(int x, int y, int width, int height, mat4 projection, mat4 view)
{
        float depth = 0.0f;
        glReadPixels(x, height - y - 1, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, cast(void*) &depth);
        /* Clip space coord */
        auto point = vec4(
            (cast(float)x / width) * 2 - 1, 
            (1 - cast(float)y / height) * 2 - 1, 
            depth * 2 - 1, 
            1);

        mat4 pvi = projection * view;
        pvi.invert(); 
        vec4 world = pvi * point;

        /* World space coord */
        return vec3(world.x / world.w, world.y / world.w, world.z / world.w);
}

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

        //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE); /* Draw backfacing as wireframe */

        TTF_Init();
    }
    
    public mat4 IsometricPerspective(float x, float y, float z) 
    {
        return mat4.identity
                   .rotatey(45 * 3.1415f / 180)
                   .rotatex(35 * 3.1415f / 180)
                   .translate(1,1,0);
    }

    public void run() 
    {
        auto cube = new IsoCube();
        cube.tesselate();

        auto plane = new Quad(5,5);
        plane.tesselate();

        auto model = mat4.identity;
        auto model2 = mat4.translation(1,0,0);
        auto model3 = mat4.translation(0,1,0);


        vec3 position = vec3(4, 3, 4);
        /* isometric view */
        auto view = IsometricPerspective(position.x, position.y, position.z);

        /* Compile shader */
        auto program = Shader.Create("basic");
        program.use();

        /* MVP */
        mat4 projection = mat4.orthographic(0, 8, 0, 6, -100, 100);
        program.setMatrix4("Projection", projection);

        auto ui = new UIManager(cast(int)size.x, cast(int)size.y);

        writeln("UI manager created");

        float r = 45.0f;
        bool mouse = false;

        uint lastTime = SDL_GetTicks();

        writeln(glGetError());

        auto material = new Material(program);
        writeln("setting diffuse?");
        material.Diffuse = new Texture("rock.jpg");

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
            //program.setVec3("CameraPos", position);
            program.setVec3("LightPos", vec3(-1,3,-1));

            //plane.draw();

            program.setMatrix4("Model", model);
            cube.draw();

            program.setMatrix4("Model", model2);
            cube.draw();

            program.setMatrix4("Model", model3);
            cube.draw();

            SDL_Event event;
            while (SDL_PollEvent(&event)) {
                ui.processEvent(event);
                switch(event.type) {
                    case SDL_QUIT:
                        run = false;
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        vec3 worldPos = Unproject(event.button.x, event.button.y, cast(int)size.x, cast(int)size.y, projection, view);
                        writefln("world: %s", worldPos);
                        mouse = true;
                        break;
                    case SDL_MOUSEBUTTONUP:
                        mouse = false;
                        break;
                    case SDL_MOUSEMOTION:
                        if (mouse) {
                            auto p = vec3(event.motion.xrel, 0, -event.motion.yrel);
                            position = position + p * 5 * dt;
                            view = IsometricPerspective(position.x, position.y, position.z);
                        }
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
