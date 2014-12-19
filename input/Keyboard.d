module input.Keyboard;

import std.stdio;
import std.string;
import derelict.sdl2.sdl;
import input;

class Keyboard
{
    private static KeyState[Keys] keyState;

    private this() { }

    /** Feed me with SDL keyboard events */
    public static void handleEvent(SDL_Event* event) 
    {
        final switch(event.type) {
            /* UTF-8 Character Input */
            case SDL_TEXTINPUT:
                auto idx = indexOf(event.text.text, '\0');
                auto character = event.text.text[0..idx];
                writeln("Text input: ", character); 
               break;
                
            /* Key Events */
            case SDL_KEYDOWN:
            case SDL_KEYUP:
                auto key = cast(Keys)event.key.keysym.sym;
                auto state = getState(key);
                state.handleEvent(event);
                break;
        }
    }

    public static KeyState* getState(Keys key) 
    {
        auto state = key in this.keyState;
        if (state is null) {
            /* Create state for this key */
            auto newState = new KeyState(key);
            keyState[key] = newState;
            state = &newState;
        }
        return state;
    }

    public static bool isKeyDown(Keys key) { return  getState(key).Pressed; }
    public static bool isKeyUp(Keys key)   { return !getState(key).Pressed; }
}
