CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread -lX11 -lXxf86vm -lXrandr -lXi

A01: A01.cpp triangles.hpp
	g++ $(CFLAGS) -o A01 A01.cpp $(LDFLAGS) -I "./headers"

test: A01
	./A01

clean:
	rm A01
