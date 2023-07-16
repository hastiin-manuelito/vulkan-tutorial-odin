All it does is return to you two extensions - VK_KHR_surface and VK_KHR_win32_surface assuming you’re on windows
[10:58 AM]
The first one is always the same, the second one depends on which OS you’re on

vkEnumerateInstanceExtensions does something completely different - it returns to you literally every instance extension supported by your graphics driver
[11:01 AM]
So no matter which GPU you’re using, so long as you’re on the same OS, glfwGetRequiredInstanceExtensions always returns the same extensions
