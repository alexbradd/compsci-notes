CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A07: A07.cpp Logic.hpp
	g++ $(CFLAGS) -o A07 A07.cpp $(LDFLAGS) -I "./headers"

test: A07
	./A07

clean:
	rm A07
