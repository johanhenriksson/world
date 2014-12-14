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

void main() 
{
    try {
        DerelictGL.load();
        DerelictSDL2.load();
        DerelictSDL2Image.load();
        DerelictSDL2ttf.load();
    }
    catch(SymbolLoadException ex) {
        writefln("Cannot find symbol %s", ex.msg); 
    }

    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();

    /* Select OpenGL Profile */
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

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
