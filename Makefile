#STB_INCLUDE_PATH = /home/derrick/.local/include/stbs


VulkanTest: vulkan_glfw.odin compileShader
	odin build vulkan_glfw.odin -file -out:VulkanTest

.PHONY: test clean compile

compileShader:
	#glslc shaders/shader.vert -o shaders/vert.spv
	#glslc shaders/shader.frag -o shaders/frag.spv

test: VulkanTest
	./VulkanTest

clean:
	rm -f VulkanTest
