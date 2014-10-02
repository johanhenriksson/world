/* External */
import std.stdio;
import std.string;
import gl3n.math;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.opengl3.gl;

import shader;
import geometry;

pragma(lib, "libSDL2-2.0.so");

void main() 
{
    DerelictGL.load();
    DerelictSDL2.load();

    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    auto window = SDL_CreateWindow(
            "SDL2 window",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            800, 600,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);

    if (!window)
        throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));

    auto glprof = SDL_GL_CreateContext(window);

    DerelictGL.reload();

    auto quad = new Quad(2, 2);
    quad.tesselate();

    /* Compile shader */
    auto program  = new ShaderProgram();
    auto vertex   = new VertexShader("shaders/basic.vs.glsl");
    auto fragment = new FragmentShader("shaders/basic.fs.glsl");

    vertex.compile();
    fragment.compile();

    program.attach(vertex);
    program.attach(fragment);
    program.link();

    glClearColor(0.2, 0.2, 0.2, 1);

    auto run = true;
    while(run) 
    {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch(event.type) {
                case SDL_QUIT:
                    run = false;
                    break;
                default: 
                    break;
            }
        }

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        program.use();
        quad.draw();

        /* Swap buffers */
        SDL_GL_SwapWindow(window);
    }

    SDL_Quit();
}
