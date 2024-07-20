#/bin/sh

if [ -f "qplus" ]; then
	make clean;
fi

make;

if [ -f "qplus" ]; then
	./qplus < input_files/input_asm_test;# &> output_compiler;
fi

#if [ -f "answer_output" ]; then
#	echo -e "\nAnswers:";
#	cat answer_output;
#fi
