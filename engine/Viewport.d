module engine.Viewport;

import derelict.opengl3.gl;
import engine;

class Viewport
{
    protected Scene scene;
    protected Camera camera;

    public this(Camera camera, Scene scene) {
        this.camera = camera;
        this.scene  = scene;
    }

    public void draw() 
    {
    }
}
