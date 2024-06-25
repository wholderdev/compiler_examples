#/bin/sh

if [ -f "qplus" ]; then
	make clean;
fi

make;

if [ -f "qplus" ]; then
	./qplus < input;
fi
