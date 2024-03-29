package main

import "core:fmt"
import sdl "vendor:sdl2"
import glm "core:math/linalg/glsl"
import vk "vendor:vulkan"

WIDTH   :: 1600
HEIGHT  :: 900
TITLE   :: "Vulkan Window!"

window : ^sdl.Window
instance : vk.Instance

run :: proc() {
    initWindow()
    initVulkan()
    mainLoop()
    cleanup()
}

initWindow :: proc() {

    sdl.Init({.VIDEO})

    window = sdl.CreateWindow("Odin SDL2 Demo", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, {.VULKAN})
    if window == nil {
        fmt.eprintln("SDL2 has failed to load the window.")
        return
    }
    defer sdl.DestroyWindow(window)
}


initVulkan :: proc() {
    createInstance()

    pCount : u32
    pNames : [^]cstring
    yes := sdl.Vulkan_GetInstanceExtensions(window, &pCount, pNames)
    fmt.println(yes)
}

mainLoop :: proc() {
    event : sdl.Event
    for sdl.PollEvent(&event) != false {
        #partial switch event.type {
        case .KEYDOWN:
            #partial switch event.key.keysym.sym {
            case .ESCAPE:
                break
            }
        case .QUIT:
            break
        }
    }
}

createInstance :: proc() {
    /*
    appInfo : vk.ApplicationInfo
    appInfo.sType = vk.StructureType.APPLICATION_INFO
    appInfo.pApplicationName = "Hello Triangle"
    appInfo.applicationVersion = vk.MAKE_VERSION(1, 0, 0)
    appInfo.pEngineName = "No Engine"
    appInfo.engineVersion = vk.MAKE_VERSION(1, 0, 0)
    appInfo.apiVersion = vk.API_VERSION_1_0

    createInfo : vk.InstanceCreateInfo
    createInfo.sType = vk.StructureType.INSTANCE_CREATE_INFO
    createInfo.pApplicationInfo = &appInfo

    extCount : u32 = 0
    extensions : [^]cstring
    // extensions = glfw.GetRequiredInstanceExtensions(&extCount)

    createInfo.enabledExtensionCount = extCount
    createInfo.ppEnabledExtensionNames = extensions
    createInfo.enabledLayerCount = 0
    result : vk.Result
    result = vk.CreateInstance(&createInfo, nil, &instance)
    if result != vk.Result.SUCCESS {
        fmt.eprintln("failed to create instance!")
    }
    */
}

cleanup :: proc() {

}


main :: proc() {
    run()
    // extCount : u32
    // vk.EnumerateInstanceExtensionProperties(nil, &extCount, nil)
    // fmt.println(extCount)
}
