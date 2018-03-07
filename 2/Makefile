default: all
all: parser

# Parser
parser: main.cpp scanner.l parser.y
	bison -d -o parser.cpp parser.y --report=state
	flex -o scanner.cpp scanner.l
	g++ -std=c++0x main.cpp parser.cpp scanner.cpp -o parser
	rm -f scanner.cpp parser.cpp parser.hpp parser.output

# Tester
# Must run with make test -i to suppress errors
test: clean parser
	mkdir output/
	./parser < testing_code/p1.py > output/p1_result.cpp
	diff output/p1_result.cpp example_output/p1.cpp ; if [ $$? -eq 0 ] ; then echo "P1 PASSED" ; fi 
	
	./parser < testing_code/p2.py > output/p2_result.cpp
	diff output/p2_result.cpp example_output/p2.cpp ; if [ $$? -eq 0 ] ; then echo "P2 PASSED" ; fi 

	./parser < testing_code/p3.py > output/p3_result.cpp
	diff output/p3_result.cpp example_output/p3.cpp ; if [ $$? -eq 0 ] ; then echo "P3 PASSED" ; fi 

	./parser < testing_code/error1.py
	./parser < testing_code/error2.py
	./parser < testing_code/error3.py

clean-shallow:
	rm -f scanner.cpp parser.cpp parser.hpp parser.output

clean: clean-shallow
	rm -rf output/
	rm -f parser
