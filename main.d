/* External */
import std.stdio;
import std.string;
import gl3n.math;
import gl3n.linalg;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.opengl3.gl;

import shader;
import geometry;
import material;

pragma(lib, "libSDL2-2.0.so");

class Transform 
{
    @property mat4 Model()    { return transform; }
    @property vec3 Position() { return position; }
    @property vec3 Scale()    { return scale; }

    @property vec3 Scale(vec3 value) {
        scale = value;
        recalculate();
        return scale;
    }

    @property vec3 Position(vec3 value) {
        position = value;
        recalculate();
        return position;
    }

    @property vec3 Rotation(vec3 value) {
        rotation = value;
        recalculate();
        return rotation;
    }

    @property vec3 Angle() {
        return rotation * (180.0f / 3.14159f);
    }

    @property vec3 Angle(vec3 value) {
        rotation = value * (3.14159f / 180.0f);
        recalculate();
        return value;
    }

    private mat4 transform;
    private vec3 position;
    private vec3 rotation;
    private vec3 scale;
    private quat rot;

    private Transform parent;
    private Transform[] nodes;

    public this() {
        position = vec3(0,0,0);
        rotation = vec3(0,0,0);
        scale    = vec3(1,1,1);
        rot      = quat.identity;
        recalculate();
    }

    public void RotateX(float degrees) {
        rot.rotatex(degrees * 3.1415f / 180.0f);
        recalculate();
    }

    public void RotateY(float degrees) {
        rot.rotatey(degrees * 3.1415f / 180.0f);
        recalculate();
    }

    private void recalculate() 
    {
        auto mat = mat4.scaling(scale.x, scale.y, scale.z); // Scale
        mat = rot.to_matrix!(4,4) * mat; // Rotate 
        mat = mat.translate(position.x, position.y, position.z); // Translate

        this.transform = mat;
    }
}

class World
{
    private SDL_Window* window;
    private SDL_GLContext context;
    private vec2 size;
    private float aspect;

    public this(float width, float height) {
        this.size = vec2(width, height);
        this.aspect = width / height;
    }

    public void init() 
    {
        /* Create Window */
        window = SDL_CreateWindow(
            "SDL2 window",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            cast(int) size.x, cast(int) size.y,
            SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN
        );
        if (!window)
            throw new Exception("Could not create OpenGL window " ~ to!string(SDL_GetError()));

        /* Create OpenGL Context */
        context = SDL_GL_CreateContext(window);

        DerelictGL.reload();
    }

    public void run() 
    {
        auto cube = new IsoCube();
        cube.tesselate();

        auto iso_root = mat4.identity
                            .rotatey(45 * 3.1415f / 180)
                            .rotatex(30 * 3.1415f / 180);

        auto model = mat4.identity
                         .rotatey(45 * 3.1415f / 180)
                         .rotatex(30 * 3.1415f / 180);
        auto model2 = iso_root * mat4.translation(1,0,0);
        auto model3 = iso_root * mat4.translation(0,-1,0);

        vec3 position = vec3(4, 3, 4);
        auto view = mat4.identity.translate(position.x, position.y, position.z);

        /* Compile shader */
        auto program  = new ShaderProgram();
        auto vertex   = new VertexShader("shaders/basic.vs.glsl");
        auto fragment = new FragmentShader("shaders/basic.fs.glsl");

        vertex.compile();
        fragment.compile();

        program.attach(vertex);
        program.attach(fragment);
        program.link();

        program.use();

        glEnable(GL_DEPTH_TEST);

        /* MVP */
        mat4 projection = mat4.orthographic(0, 8, 0, 6, -10000, 10000);
        program.setMatrix4("Projection", projection);

        glClearColor(0.2, 0.2, 0.2, 1);

        float r = 45.0f;
        bool mouse = false;

        uint lastTime = SDL_GetTicks();

        auto material = new Material(program);
        material.Diffuse = new Texture("rock.jpg");
        material.use();

        writeln(glGetError());

        auto run = true;
        while(run) 
        {
            uint time = SDL_GetTicks();
            float dt = (time - lastTime) / 1000.0f;
            lastTime = time;

            SDL_Event event;
            while (SDL_PollEvent(&event)) {
                switch(event.type) {
                    case SDL_QUIT:
                        run = false;
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        mouse = true;
                        break;
                    case SDL_MOUSEBUTTONUP:
                        mouse = false;
                        break;
                    case SDL_MOUSEMOTION:
                        if (mouse) {
                            auto p = vec3(event.motion.xrel, -event.motion.yrel, 0);
                            position = position + p * 5 * dt;
                            view = mat4.translation(position.x, position.y, position.z);
                        }
                        break;
                    default: 
                        break;
                }
            }

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

            program.setMatrix4("View", view);

            program.setMatrix4("Model", model);
            cube.draw();

            program.setMatrix4("Model", model2);
            cube.draw();

            program.setMatrix4("Model", model3);
            cube.draw();

            /* Swap buffers */
            SDL_GL_SwapWindow(window);
        }
    }
}

void main() 
{
    DerelictGL.load();
    DerelictSDL2.load();
    DerelictSDL2Image.load();

    SDL_Init(SDL_INIT_VIDEO);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

    auto world = new World(800, 600);
    world.init();
    world.run();

    SDL_Quit();
}
