#CFLAGS = -std=c++17 -O2
#STB_INCLUDE_PATH = /home/derrick/.local/include/stbs

LDFLAGS ="-lglfw -lvulkan -ldl -lpthread -lX11 -lXxf86vm -lXrandr -lXi -lwayland-client -lwayland-server"
#CFLAGS=-DDEBUG

#CFLAGS=-O2

#CC= -std=c++17 $(CFLAGS)

#compileShader

VulkanTest: vulkan_glfw.odin
	odin build vulkan_glfw.odin -file -out:VulkanTest -extra-linker-flags=$(LDFLAGS)

.PHONY: test clean compile

#compileShader:
	#glslc shaders/shader.vert -o shaders/vert.spv
	#glslc shaders/shader.frag -o shaders/frag.spv

test: VulkanTest
	./VulkanTest

clean:
	rm -f VulkanTest