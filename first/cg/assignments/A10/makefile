CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A10: A10.cpp shaders
	g++ $(CFLAGS) -o A10 A10.cpp $(LDFLAGS) -I "./headers"

shaders: shaders/PhongFrag.spv shaders/PhongVert.spv

shaders/PhongFrag.spv: shaders/PhongShader.frag
	glslc -o shaders/PhongFrag.spv shaders/PhongShader.frag

shaders/PhongVert.spv: shaders/PhongShader.vert
	glslc -o shaders/PhongVert.spv shaders/PhongShader.vert

test: A10
	./A10

clean:
	rm A10    || true
	rm shaders/*.spv || true
