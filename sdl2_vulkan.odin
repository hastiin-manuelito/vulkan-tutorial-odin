package main

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:time"

import sdl "vendor:sdl2"
import gl "vendor:OpenGL"
import vk "vendor:vulkan"

GL_VERSION_MAJOR :: 3
GL_VERSION_MINOR :: 3

main :: proc() {
    WINDOW_WIDTH  :: 854
    WINDOW_HEIGHT :: 480

    sdl.Init({.VIDEO})
    defer sdl.Quit()

    window := sdl.CreateWindow("Odin SDL2 Demo", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, {.VULKAN})
    if window == nil {
        fmt.eprintln("Failed to create window")
        return
    }
    defer sdl.DestroyWindow(window)

    // sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK,  i32(sdl.GLprofile.CORE))
    // sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION,  GL_VERSION_MAJOR)
    // sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION,  GL_VERSION_MINOR)

    // gl_context := sdl.GL_CreateContext(window)
    // defer sdl.GL_DeleteContext(gl_context)

    // load the OpenGL procedures once an OpenGL context has been established
    // gl.load_up_to(GL_VERSION_MAJOR, GL_VERSION_MINOR, sdl.gl_set_proc_address)

    // useful utility procedures that are part of vendor:OpenGL
    // program, program_ok := gl.load_shaders_source(vertex_source, fragment_source)
    // if !program_ok {
        // fmt.eprintln("Failed to create GLSL program")
        // return
    // }
    // defer gl.DeleteProgram(program)

    // gl.UseProgram(program)

    // uniforms := gl.get_uniforms_from_program(program)
    // defer delete(uniforms)

    // vao: u32
    // gl.GenVertexArrays(1, &vao); defer gl.DeleteVertexArrays(1, &vao)
    // gl.BindVertexArray(vao)

    // initialization of OpenGL buffers
    // vbo, ebo : u32
    // gl.GenBuffers(1, &vbo); defer gl.DeleteBuffers(1, &vbo)
    // gl.GenBuffers(1, &ebo); defer gl.DeleteBuffers(1, &ebo)

    // struct declaration
    Vertex :: struct {
        pos: glm.vec3,
        col: glm.vec4,
    }

    vertices := []Vertex{
        {{-0.5, +0.5, 0.0}, {1.0, 0.0, 0.0, 0.75}},
        {{-0.5, -0.5, 0.0}, {1.0, 1.0, 0.0, 0.75}},
        {{+0.5, -0.5, 0.0}, {0.0, 1.0, 0.0, 0.75}},
        {{+0.5, +0.5, 0.0}, {0.0, 0.0, 1.0, 0.75}},
    }

    indices := []u16{
        0, 1, 2,
        2, 3, 0,
    }

    // gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    // gl.BufferData(gl.ARRAY_BUFFER, len(vertices)*size_of(vertices[0]), raw_data(vertices), gl.STATIC_DRAW)
    // gl.EnableVertexAttribArray(0)
    // gl.EnableVertexAttribArray(1)
    // gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, pos))
    // gl.VertexAttribPointer(1, 4, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, col))

    // gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    // gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices)*size_of(indices[0]), raw_data(indices), gl.STATIC_DRAW)

    // high precision timer
    start_tick := time.tick_now()

    /*
    loop: for {
        duration := time.tick_since(start_tick)
        t := f32(time.duration_seconds(duration))

        // event polling
        event: sdl.Event
        for sdl.PollEvent(&event) != false {
            // #partial switch tells the compiler not to error if every case is not present
            #partial switch event.type {
            case .KEYDOWN:
                #partial switch event.key.keysym.sym {
                case .ESCAPE:
                    // labelled control flow
                    break loop
                }
            case .QUIT:
                // labelled control flow
                break loop
            }
        }

        // Native support for GLSL-like functionality
        pos := glm.vec3{
            glm.cos(t*2),
            glm.sin(t*2),
            0,
        }

        // array programming support
        pos *= 0.3

        // matrix support
        // model matrix which a default scale of 0.5
        model := glm.mat4{
            0.5, 0.0, 0.0, 0.0,
            0.0, 0.5, 0.0, 0.0,
            0.0, 0.0, 0.5, 0.0,
            0.0, 0.0, 0.0, 1.0,
        }

        // matrix indexing and array short with `.x`
        model[0, 3] = -pos.x
        model[1, 3] = -pos.y
        model[2, 3] = -pos.z

        // native swizzling support for arrays
        model[3].yzx = pos.yzx

        model = model * glm.mat4Rotate({0, 1, 1}, t)

        view := glm.mat4LookAt({0, -1, +1}, {0, 0, 0}, {0, 0, 1})
        proj := glm.mat4Perspective(45, 1.3, 0.1, 100.0)

        // matrix multiplication
        u_transform := proj * view * model

        // matrix types in Odin are stored in column-major format but written ast you'd normal write them
        gl.UniformMatrix4fv(uniforms["u_transform"].location, 1, false, &u_transform[0, 0])

        gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        gl.ClearColor(0.5, 0.7, 1.0, 1.0)
        gl.Clear(gl.COLOR_BUFFER_BIT)

        gl.DrawElements(gl.TRIANGLES, i32(len(indices)), gl.UNSIGNED_SHORT, nil)

        sdl.GL_SwapWindow(window)
    }
    */
}


vertex_source := `#version 330 core


layout(location = 0) in vec3 a_position;
layout(location = 1) in vec4 a_color;

out vec4 v_color;

uniform mat4 u_transform;

void main() {
    gl_Position = u_transform * vec4(a_position, 1.0);
    v_color = a_color;
}
`

fragment_source := `#version 330 core

in vec4 v_color;

out vec4 o_color;

void main() {
    o_color = v_color;
}
`