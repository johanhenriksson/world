module ui.UIText;

import gl3n.linalg;
import shader;
import material;
import ui;

class UIText : UIElement
{
    @property string Text() { return text; }
    @property vec4 Color() { return color; }
    @property Font TextFont() { return font; }

    @property string Text(string value) {
        text = value;
        refresh();
        return text;
    }

    @property vec4 Color(vec4 value) {
        color = value;
        refresh();
        return color;
    }

    private UITexture texture;
    private Font font;
    private string text;
    private vec4 color;

    public this(vec2 position, string text, vec4 color, Font font) 
    {
        super(vec3(position.x, position.y, 0), vec2(0,0));
        this.font = font;
        this.text = text;
        this.color = color;

        auto surface   = font.Render(text, color);
        auto gltexture = new Texture(surface);
        this.texture   = new UITexture(gltexture);
        this.texture.tesselate();
    }

    protected void refresh() 
    {
        /* Ugly as fuck */
        auto surface = this.font.Render(text, color);
        texture.GLTexture.loadFromSurface(surface);
        size = vec2(texture.GLTexture.Width, texture.GLTexture.Height);
    }

    public override void drawTextured(Shader shader) {
        shader.setMatrix4("Transform", transform.Matrix);
        texture.drawTextured(shader);
    }
}
