## Chapter 0

In Odin we only need to import the vulkan libraries (it pretty much just works), they must be installed of course (see above). For this tutorial we don't need to worry about linking any libraries. The code herein does not attempt to mirror conventional Odin style, that is the style that comes up naturally having worked with Odin for a significant amount of time. This code is semantically and syntactically correct as it does compile.

The tutorial is broken up into chapters. Each chapter will have its own branch.

### Set up environment

This tutorial is ported directly from [here](https://vulkan-tutorial.com).

If you like using an IDE please go here: https://vulkan-tutorial.com/Development_environment to set it up.

It is recommended to use the LunarG SDK, available here: https://vulkan.lunarg.com/. The SDK provides validation layers that people really like (I guess).


### Initialize glfw

glfw3 will be used to initialize the window.

```odin
package main

import "core:fmt"
import "vendor:glfw"
import vk "vendor:vulkan"


WIDTH   :: 1600
HEIGHT  :: 900
TITLE   :: "Vulkan Window!"

window : glfw.WindowHandle

initWindow :: proc() {
    if !bool(glfw.Init()) {
        fmt.eprintln("GLFW has failed to load.")
        return
    }
    gl_false : i32 = 0
    glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
    glfw.WindowHint(glfw.RESIZABLE, gl_false)

    window := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)
    if window == nil {
        fmt.eprintln("GLFW has failed to load the window.")
        return
    } else {
        fmt.println("[LOG] Window initialized!")
    }
}

main :: proc() {
    initWindow()
}
```

### Compile
We will be compiling this program with `make` because other popular build systems are just terrible.

run

`make`
or
`make clean && make` Having built the executable before

The shaders in the shaders directories will not be used until later chapters
