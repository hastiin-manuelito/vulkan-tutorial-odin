package main

import "core:fmt"
import "vendor:glfw"
import glm "core:math/linalg/glsl"
import vk "vendor:vulkan"
import "core:strings"


WIDTH   :: 1600
HEIGHT  :: 900
TITLE   :: "Vulkan Window!"

validationLayers := []cstring{"VK_LAYER_KHRONOS_validation"}

when ODIN_DEBUG {
    enabledValidationLayers := false
} else {
    enabledValidationLayers := true
}

check_ValidationLayerSupport :: proc() -> b32 {
    layerCount : u32
    vk.EnumerateInstanceLayerProperties(&layerCount, nil)
    availableLayers := make([]vk.LayerProperties, layerCount)
    vk.EnumerateInstanceLayerProperties(&layerCount, raw_data(availableLayers))

    compare_strings :: proc(layerProperties : vk.LayerProperties, validation_string : cstring) -> bool {
        bytes : [256]u8 = layerProperties.layerName
        builder := strings.clone_from_bytes(bytes[:])
        cbuilder := strings.clone_to_cstring(builder)
        return cbuilder == validation_string
    }

    for layerName in validationLayers {
        layerFound := false

        for layerProperties in availableLayers {
            // Cannot directly slice from "layerProperties.layerName
            if compare_strings(layerProperties, layerName) == true do return true
        }
    }
    return false
}

// Globals
window : glfw.WindowHandle
instance : vk.Instance


initWindow :: proc() {
    if !bool(glfw.Init()) {
        fmt.eprintln("GLFW has failed to load.")
        return
    }
    gl_false : i32 = 0
    glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
    glfw.WindowHint(glfw.RESIZABLE, gl_false)

    window = glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)
    if window == nil {
        fmt.eprintln("GLFW has failed to load the window.")
        return
    }
}


initVulkan :: proc() {
    createInstance()
    is_supported := check_ValidationLayerSupport()
    if is_supported do fmt.println("Yes")
}


createInstance :: proc() {
    fmt.println("Made it here")
    vk.load_proc_addresses(rawptr(glfw.GetInstanceProcAddress))

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

    extensions := glfw.GetRequiredInstanceExtensions()
    glfwExtCount := u32(len(extensions))
    extensionsC := raw_data(glfw.GetRequiredInstanceExtensions())

    createInfo.enabledExtensionCount = glfwExtCount
    createInfo.ppEnabledExtensionNames = extensionsC
    createInfo.enabledLayerCount = 0
    result : vk.Result

    result = vk.CreateInstance(&createInfo, nil, &instance)
    if result != vk.Result.SUCCESS {
        fmt.eprintln("failed to create instance!")
    }
    vk.load_proc_addresses_instance(instance)

    reqExt : []string
    extCount : u32
    vk.EnumerateInstanceExtensionProperties(nil, &extCount, nil)
    extensionProps := make([]vk.ExtensionProperties, extCount)
    vk.EnumerateInstanceExtensionProperties(nil, &extCount, raw_data(extensionProps))
    fmt.println("available extensions:\n")
    for ext in extensionProps {
        for c in ext.extensionName {
            fmt.printf("%c", c)
        }
        fmt.println()
    }
    fmt.println(extCount)
}


mainLoop :: proc() {
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
    }
}


cleanup :: proc() {
    vk.DestroyInstance(instance, nil)
    glfw.DestroyWindow(window)
    glfw.Terminate()
}


main :: proc() {
    initWindow()
    initVulkan()
    mainLoop()
    cleanup()
}
