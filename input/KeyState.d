module input.KeyState;

import std.stdio;
import derelict.sdl2.sdl;
import input;

class KeyState
{
    @property bool Pressed() { return keyPressed; }
    @property Keys KeyCode() { return keyCode; }

    protected Keys keyCode;
    protected bool keyPressed;

    public this(Keys code) 
    {
        this.keyCode = code;
        this.keyPressed = false;
    }

    public void handleEvent(SDL_Event* event) 
    {
        final switch(event.type) {
            case SDL_KEYDOWN:
                keyPressed = true;
                break;
            case SDL_KEYUP:
                keyPressed = false;
                break;
        }
    }
}
