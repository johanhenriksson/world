module engine.Viewport;

import std.stdio;
import gl3n.linalg;
import derelict.opengl3.gl;
import engine;

class Viewport
{
    @property mat4 View() { return camera.ViewMatrix; }
    @property mat4 Projection() { return camera.ProjectionMatrix; }

    public Scene scene;
    public Camera camera;
    protected Entity heightmap;

    public this(Camera camera, Scene scene) {
        this.camera = camera;
        this.scene  = scene;

        heightmap = new Entity();
        heightmap.transform.Position = vec3(-5,0,-5);
        auto renderer = new HeightMapRenderer(heightmap);
        heightmap.attach(renderer);
    }

    public void tick(float dt, float time) {
        camera.tick(dt, time);
        //scene.tick(dt, time);
    }

    public void draw() 
    {
        heightmap.draw(this);
    }
}
