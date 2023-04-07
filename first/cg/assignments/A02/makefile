CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A02: A02.cpp transforms.hpp
	g++ $(CFLAGS) -o A02 A02.cpp $(LDFLAGS) -I "./headers"

test: A02
	./A02

clean:
	rm A02
