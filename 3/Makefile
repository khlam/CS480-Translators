default: all
all: parser

# Parser
parser: main.cpp scanner.l parser.y ast.h ast.c
	bison -d -o parser.cpp parser.y --report=state
	flex -o scanner.cpp scanner.l
	g++ -std=c++0x main.cpp parser.cpp scanner.cpp ast.c -o parser -g
	rm -f scanner.cpp parser.cpp parser.hpp parser.output

# Tester
test: clean parser
	mkdir output/
	./parser < testing_code/p1.py > output/p1_result.gv
	#cat output/p1_result.gv
	dot -Tpng output/p1_result.gv > output/p1_result.png
	diff output/p1_result.gv example_output/p1.gv ; if [ $$? -eq 0 ] ; then echo "P1 PASSED" ; fi 

	./parser < testing_code/p2.py > output/p2_result.gv
	#cat output/p2_result.gv
	dot -Tpng output/p2_result.gv > output/p2_result.png
	diff output/p2_result.gv example_output/p2.gv ; if [ $$? -eq 0 ] ; then echo "P2 PASSED" ; fi 

	./parser < testing_code/p3.py > output/p3_result.gv
	#cat output/p3_result.gv
	dot -Tpng output/p3_result.gv > output/p3_result.png
	diff output/p3_result.gv example_output/p3.gv ; if [ $$? -eq 0 ] ; then echo "P3 PASSED" ; fi 

clean-shallow:
	rm -f scanner.cpp parser.cpp parser.hpp parser.output

clean: clean-shallow
	rm -rf output/
	rm -f parser
	rm -f *.png
