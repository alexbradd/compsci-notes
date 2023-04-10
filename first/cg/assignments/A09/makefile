CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

### V1

A09: A09.cpp shaders/PhongFrag.spv shaders/PhongVert.spv
	g++ $(CFLAGS) -o A09 A09.cpp $(LDFLAGS) -I "./headers"

shaders/PhongFrag.spv: shaders/PhongShader.frag
	glslc -o shaders/PhongFrag.spv shaders/PhongShader.frag

shaders/PhongVert.spv: shaders/PhongShader.vert
	glslc -o shaders/PhongVert.spv shaders/PhongShader.vert

### V2

A09_v2: A09.cpp shaders/PhongFrag.spv_v2 shaders/PhongVert.spv_v2
	g++ $(CFLAGS) -o A09_v2 A09.cpp $(LDFLAGS) -I "./headers"

shaders/PhongFrag.spv_v2: shaders/PhongShader.v2.frag
	glslc -o shaders/PhongFrag.spv shaders/PhongShader.v2.frag

shaders/PhongVert.spv_v2: shaders/PhongShader.v2.vert
	glslc -o shaders/PhongVert.spv shaders/PhongShader.v2.vert

### Test and clean

test: A09
	./A09

test_v2 : A09_v2
	./A09_v2

clean:
	rm A09    || true
	rm A09_v2 || true
	rm shaders/*.spv || true
