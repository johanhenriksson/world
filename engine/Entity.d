module engine.Entity;

import std.string;
import std.format;
import engine;

/** Anything that resides in the game world */
class Entity
{
    private static int nextId = 0;

    @property int Id() { return id; }
    @property string Name() { return name; }

    public Transform transform;
    protected Component[] components;

    private int id;
    private string name;

    public this() {
        this.id = ++Entity.nextId;
        this.transform = new Transform(this);
        this.attach(transform);
    }

    public void attach(Component component) {
        components ~= component;
    }

    public void tick(float dt, float time) {
        foreach(component; this.components)
            component.tick(dt, time);
    }

    public void draw(Viewport viewport) {
        foreach(component; this.components)
            component.draw(viewport);
    }
}
