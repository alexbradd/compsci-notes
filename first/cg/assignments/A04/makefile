CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A04: A04.cpp projection.hpp
	g++ $(CFLAGS) -o A04 A04.cpp $(LDFLAGS) -I "./headers"

test: A04
	./A04

clean:
	rm A04
