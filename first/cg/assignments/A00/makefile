CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread -lX11 -lXxf86vm -lXrandr -lXi

A00: A00.cpp
	g++ $(CFLAGS) -o A00 A00.cpp $(LDFLAGS) -I "./headers"

test: A00
	./A00

clean:
	rm A00
