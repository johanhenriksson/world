module engine.Component;

import engine;

class Component
{
    public Entity entity;
    @property Transform transform() { return entity.transform; }

    public this(Entity entity) {
        this.entity = entity;
    }

    public void tick(float dt, float time) { }
    public void draw(Viewport viewport) { }
}
