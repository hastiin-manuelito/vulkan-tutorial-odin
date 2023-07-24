package main

import "core:fmt"
import "vendor:glfw"
import glm "core:math/linalg/glsl"
import vk "vendor:vulkan"
import "core:strings"


WIDTH   :: 1600
HEIGHT  :: 900
TITLE   :: "Vulkan Window!"

QueueError :: enum {
    None,
    NoGraphicsBit,
}


validationLayers := []cstring{"VK_LAYER_KHRONOS_validation"}

when ODIN_DEBUG {
    enabledValidationLayers := true
} else {
    enabledValidationLayers := false
}

check_ValidationLayerSupport :: proc() -> b32 {
    layerCount : u32
    vk.EnumerateInstanceLayerProperties(&layerCount, nil)
    availableLayers := make([]vk.LayerProperties, layerCount)
    vk.EnumerateInstanceLayerProperties(&layerCount, raw_data(availableLayers))

    compare_strings :: proc(layerProperties : vk.LayerProperties, validation_string : cstring) -> bool {
        // Cannot directly slice from "layerProperties.layerName
        bytes : [256]u8 = layerProperties.layerName
        builder := strings.clone_from_bytes(bytes[:])
        cbuilder := strings.clone_to_cstring(builder)
        return cbuilder == validation_string
    }

    for layerName in validationLayers {
        layerFound := false

        for layerProperties in availableLayers {
            if compare_strings(layerProperties, layerName) == true do return true
        }
    }
    return false
}

// Globals
window : glfw.WindowHandle
instance : vk.Instance
device : vk.Device


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
    pickPhysicalDevice()
}


createInstance :: proc() {
    vk.load_proc_addresses(rawptr(glfw.GetInstanceProcAddress))
    if enabledValidationLayers && !check_ValidationLayerSupport() {
        fmt.eprintln("validation layers requested but not available")
    }

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

    // fmt.println("Number of validation layers: ", len(validationLayers))

    if enabledValidationLayers {
        createInfo.enabledLayerCount = u32(len(validationLayers))
        createInfo.ppEnabledLayerNames = raw_data(validationLayers)
    } else {
        createInfo.enabledLayerCount = 0
    }
}


pickPhysicalDevice :: proc() {
    devCount : u32 = 0
    vk.EnumeratePhysicalDevices(instance, &devCount, nil);

    if devCount == 0 {
        fmt.eprintln("failed to find GPUs with Vulkan support!")
    }

    physicalDevices := make([]vk.PhysicalDevice, devCount)
    physicalDevices_raw := raw_data(physicalDevices)
    vk.EnumeratePhysicalDevices(instance, &devCount, physicalDevices_raw);


    isDeviceSuitable :: proc(device: vk.PhysicalDevice) -> b32 {
        _, err := findQueueFamilies(device)
        if err != nil {
            fmt.eprintln("Triggered an error:", err)
            return false
        }
        return true
    }


    findQueueFamilies :: proc(physicalDevice : vk.PhysicalDevice) -> (index : int, err : QueueError) {
        queueFamilyCount : u32 = 0
        vk.GetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, nil);

        queueFamilies := make([]vk.QueueFamilyProperties, queueFamilyCount)
        queueFamiliesRaw := raw_data(queueFamilies)
        vk.GetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, queueFamiliesRaw);

        i : int = 0
        for queueFamily in queueFamilies {
            if .GRAPHICS in queueFamily.queueFlags {
                index = i;
                return index, .None
            }
            i += 1
        }
        return index, .NoGraphicsBit
    }

    index : int
    for i in 0..<devCount {
        if isDeviceSuitable(physicalDevices[i]) {
            fmt.println("[LOG] A suitable device was found.")
            index = int(i)
            break;
        }
    }

    if physicalDevices == nil {
        fmt.eprintln("failed to find a suitable GPU!")
    }

    createLogicalDevice :: proc(index: int, physicalDevices : []vk.PhysicalDevice) {
        queueCreateInfo : vk.DeviceQueueCreateInfo
        queueCreateInfo.sType = vk.StructureType.DEVICE_QUEUE_CREATE_INFO
        queueCreateInfo.queueFamilyIndex = u32(index)
        queueCreateInfo.queueCount = 1
        queuePriority : f32 = 1.0
        queueCreateInfo.pQueuePriorities = &queuePriority

        deviceFeatures : vk.PhysicalDeviceFeatures
        createInfo : vk.DeviceCreateInfo
        createInfo.sType = vk.StructureType.DEVICE_CREATE_INFO
        createInfo.pQueueCreateInfos = &queueCreateInfo
        createInfo.queueCreateInfoCount = 1;

        createInfo.pEnabledFeatures = &deviceFeatures
        createInfo.enabledExtensionCount = 0;

        if enabledValidationLayers {
            createInfo.enabledLayerCount = u32(len(validationLayers))
            createInfo.ppEnabledLayerNames = raw_data(validationLayers)
        } else {
            createInfo.enabledLayerCount = 0
        }
        if vk.CreateDevice(physicalDevices[index], &createInfo, nil, &device) != vk.Result.SUCCESS {
            fmt.eprintln("Failed to create logical device!")
        } else {
            fmt.println("[LOG] found a logic device")
        }
    }

    createLogicalDevice(index, physicalDevices)
}


mainLoop :: proc() {
    for !glfw.WindowShouldClose(window) {
        glfw.PollEvents()
    }
}


cleanup :: proc() {
    vk.DestroyDevice(device, nil)
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
