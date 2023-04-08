CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A05: A05.cpp projection.hpp
	g++ $(CFLAGS) -o A05 A05.cpp $(LDFLAGS) -I "./headers"

test: A05
	./A05

clean:
	rm A05
