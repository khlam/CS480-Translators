default: all

scanner: scanner.l
	flex -o scanner.cpp scanner.l

main: main.cpp scanner.cpp
	g++ main.cpp scanner.cpp -o scan

all: scanner main

test: clean all
	./scan < testing_code/p1.py > p1_result.out
	diff p1_result.out example_output/p1.out ; if [ $$? -eq 0 ] ; then echo "P1 PASSED" ; fi 

	./scan < testing_code/p2.py > p2_result.out
	diff p2_result.out example_output/p2.out ; if [ $$? -eq 0 ] ; then echo "P2 PASSED" ; fi 

	./scan < testing_code/p3.py > p3_result.out
	diff p3_result.out example_output/p3.out ; if [ $$? -eq 0 ] ; then echo "P3 PASSED" ; fi 

	./scan < testing_code/p4.py > p4_result.out
	diff p4_result.out example_output/p4.out ; if [ $$? -eq 0 ] ; then echo "P4 PASSED" ; fi

	./scan < testing_code/p4.py > p5_result.out
	diff p5_result.out example_output/p4.out ; if [ $$? -eq 0 ] ; then echo "P5 REPLACE TAB WITH SPACES PASSED" ; fi 

clean:
	rm -f scan
	rm -f scanner.cpp
	rm -f *.out
