module engine.HeightMapRenderer;

import gl3n.linalg;
import engine;
import shader;
import geometry;
import material;

class HeightMapRenderer : Component
{
    Shader shader;
    Material material;
    HeightMap heightmap;

    public this(Entity entity) 
    {
        super(entity);
        heightmap = new HeightMap(15, 15);
        heightmap.tesselate();
        shader = Shader.Create("basic");

        shader.use();
        material = new Material(shader);
        material.Diffuse = new Texture("assets/rock.jpg");
    }

    public override void draw(Viewport viewport) 
    {
        shader.use();
        material.use();
        shader.setMatrix4("Projection", viewport.Projection);
        shader.setMatrix4("View", viewport.View);
        shader.setMatrix4("Model", mat4.identity); // entity.transform.ModelMatrix);
        shader.setVec3("CameraPos", viewport.camera.transform.Position);
        shader.setVec3("LightPos", vec3(7,7,7));
        heightmap.draw();
    }
}
