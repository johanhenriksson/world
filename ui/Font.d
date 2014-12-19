module ui.Font;

import std.string;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

class Font
{
    protected TTF_Font* ttf_font;
    protected int size;

    public this(string path, int point_size) 
    {
        auto cstr = toStringz(path);
        ttf_font = TTF_OpenFont(cstr, 20);
        if (!ttf_font)
            throw new Exception(format("Could not load ttf font: %s", path));
    }

    public SDL_Surface* Render(string text, vec4 color) 
    {
        /* Convert arguments */
        SDL_Color sdl_color = {
            cast(ubyte)( color.x * 255 ), // R
            cast(ubyte)( color.y * 255 ), // G
            cast(ubyte)( color.z * 255 ), // B
            cast(ubyte)( color.w * 255 ), // A
        };
        auto cstr = toStringz(text);

        /* Render to texture */
        auto surface = TTF_RenderUTF8_Blended(ttf_font, cstr, sdl_color);
        return surface;
    }
}
