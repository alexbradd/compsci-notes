CFLAGS = -std=c++17 -O2
LDFLAGS = -lglfw -lvulkan -ldl -lpthread

A03: A03.cpp transforms.hpp
	g++ $(CFLAGS) -o A03 A03.cpp $(LDFLAGS) -I "./headers"

test: A03
	./A03

clean:
	rm A03
