CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A06: A06.cpp WorldView.hpp
	g++ $(CFLAGS) -o A06 A06.cpp $(LDFLAGS) -I "./headers"

test: A06
	./A06

clean:
	rm A06
