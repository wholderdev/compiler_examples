#/bin/sh

if [ -f "qplus" ]; then
	make clean;
fi

make;

if [ -f "qplus" ]; then
	./qplus < task_input;
fi

#if [ -f "answer_output" ]; then
#	echo -e "\nAnswers:";
#	cat answer_output;
#fi
