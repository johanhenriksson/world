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

class Time
{
    @property static float Elapsed() { return elapsed; }
    @property static float Delta() { return delta; }

    private static float start_time;
    private static float frame_time;
    private static float elapsed;
    private static float delta;

    public static void start() 
    {
        auto ticks = SDL_GetTicks();
        start_time = ticks / 1000.0f;
        frame_time = (ticks - 1) / 1000.0f;
    }

    public static void tick() 
    {
        auto time = SDL_GetTicks() / 1000.0f;
        elapsed = time - start_time;
        delta = time - frame_time;
        frame_time = time;
    }
}

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

    Time.start();
    while(wnd.isOpen) 
    {
        Time.tick();

        wnd.tick(Time.Delta, Time.Elapsed);
        wnd.draw();

        /* Delay to target frame rate */
        float delay = targetFrameTime - Time.Delta;
        if (delay > 0.0f)
            SDL_Delay(cast(uint)( delay * 1000 ));
    }

    /* Quit */

    SDL_Quit();
}
