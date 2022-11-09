#!/bin/bash
if [ $# -eq 0 ] || [ $# -ge 2 ]
then 
	echo Usage \./hw1.sh MAXPOINTS
else
	echo Maximum score $1
	cd students
	for student_dir in */ 
		do
		cd $student_dir
		student_name=${student_dir%/}
		echo Processing $student_name ...
		if test -f "task1.sh"
		then
	    		chmod +x task1.sh
	    		./task1.sh > result.txt
	    		expected=$(dirname $(dirname $(pwd)))
	    		expected+=/expected.txt
			errors=$(diff -w -y --suppress-common-lines $expected result.txt | wc -l )
			result=$1
			if [ $errors -eq 0 ]
			then
				echo $student_name has correct output
			else
				echo $student_name has incorrect output \($errors lines do not match\)
				result=$(($1 - $errors * 5))
				if [ $result -le 0 ]
				then 
					result=0	
				fi
			fi
			echo $student_name has earned a score of $result / $1
			rm result.txt 
	    		
	    	else
	    		echo $student_name did not turn in the assignment
		fi
		cd ..
		echo
		done
fi
