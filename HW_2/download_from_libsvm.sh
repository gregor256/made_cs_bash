#!/bin/bash
# chech if all txt files are downloaded
function all_are_true() {
	arr=("$@")
	ok=1
	for el in "${arr[@]}"
	do
		# echo "$el"
		if [[ $el -eq 0 ]] ;then
			ok=0
			break
			
		fi
	done
	if [ $ok -eq 0 ]; then 
		echo 0
	else
		echo 1
	fi
}
# files num
let N=9
csv=.csv
a=a


#is i-th txt is ready to converting
# 0 -> not exists; 1 -> is creating; 2 -> was created before script running
is_ith_ready=()
let i=0
while [ $i -lt $N ]
do
	is_ith_ready+=(0)
	let i=i+1
done


#is i-th csv converted
is_ith_ready_csv=()
let i=0
while [ $i -lt $N ]
do
	is_ith_ready_csv+=(0)
	let i=i+1
done





mkdir -p datasets
mkdir -p datasets/csv
mkdir -p datasets/txt
txt_file_directory=datasets/txt/
csv_file_directory=datasets/csv/
source=https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/datasets/binary/
let num=0
while [ $num -lt $N ]
do
	let dataset_num=num+1
	file_name="$a$dataset_num$a"

	current_source="$source${file_name}"
	current_txt_file="$txt_file_directory$file_name"
	current_csv_file="$csv_file_directory$file_name$csv"

	# checking file existance
	if  ! $(test -f $current_txt_file) ; then
		echo "$file_name is downloading"
		wget -q -P $txt_file_directory $current_source & 
	else
		echo "$file_name already exists"
		is_ith_ready[$num]=2
	fi

	let check_num=0

	# after every download try to convert all txt with numbers 1..num
	while [ $check_num -le $num ]
	do	
		let check_dataset_num=check_num+1	
		check_file_name="$a$check_dataset_num$a"
		check_txt_file="$txt_file_directory$check_file_name"
		check_csv_file="$csv_file_directory$check_file_name$csv"
		# ith txt already exists
		if [ ${is_ith_ready[$check_num]} -eq 2 ]; then
			# ith csv not exists
			if ! $(test -f "$check_csv_file$csv"); then
				echo "$check_file_name downloaded and now is reading"
				# wormatting ith txt
				python3 formatting.py $check_txt_file $check_csv_file & 
				is_ith_ready[$check_num]=1
			else
				# wasn't report that ith csv is created but ith csv exists
				if [ ${is_ith_ready_csv[$check_num]} -eq 0 ]; then
					echo "$check_file_name is read"
					is_ith_ready_csv[$check_num]=1
				fi
			fi
		fi

        # if 1 or 2 then converting is running or redundant
		if [ ${is_ith_ready[$check_num]} -eq 0 ]; then
			# ith txt downloaded
			if $(test -f $check_txt_file); then
				echo "$check_file_name downloaded and now is reading"
				python3 formatting.py $check_txt_file $check_csv_file & 
				is_ith_ready[$check_num]=1
			fi
		fi
		# ith txt converting
		if [ ${is_ith_ready[$check_num]} -eq 1 ]; then
			# ith csv created
			if  $(test -f "$check_csv_file$csv") ;then
				echo "$check_file_name is read"
				is_ith_ready_csv[$check_num]=1
			fi

		fi
		let check_num=check_num+1
	done
	let num=num+1
done

# while not all txt started converting check if one is ready
result=$(all_are_true "${is_ith_ready[@]}")
while [ $result -ne 1 ]
do
	let check_num=0
	while [ $check_num -lt $N ]
	do
		let dataset_num=$check_num+1
		check_file_name="$a$dataset_num$a"
		check_txt_file="$txt_file_directory$check_file_name"
		check_csv_file="$csv_file_directory$check_file_name$csv"
		# ith txt is not downloaded
		if [ ${is_ith_ready[$check_num]} -eq 0 ]; then
			if $(test -f $check_txt_file); then
				echo "$check_file_name downloaded and now is reading"
				python3 formatting.py $check_txt_file $check_csv_file & 
				is_ith_ready[$check_num]=1
			fi
		fi


		check_csv_file="$csv_file_directory$check_file_name$csv"
		# wasn't report that ith csv is created but ith csv exists
		if [ ${is_ith_ready_csv[$check_num]} -eq 0 ]; then
			if $(test -f $check_csv_file); then
				echo "$check_file_name is read" 
				is_ith_ready_csv[$check_num]=1
			fi
		fi
		let check_num=check_num+1
	done
	result=$(all_are_true "${is_ith_ready[@]}")
done



# endless loop untill all csv created
result=$(all_are_true "${is_ith_ready_csv[@]}")
while [ $result -ne 1 ]
do
	let check_num=0
	while [ $check_num -lt $N ]
	do
		let dataset_num=$check_num+1
		check_file_name="$a$dataset_num$a"
		check_csv_file="$csv_file_directory$check_file_name$csv"
		# echo $check_csv_file
		if [ ${is_ith_ready_csv[$check_num]} -eq 0 ]; then
			if $(test -f $check_csv_file); then
				echo "$check_file_name is read" 
				is_ith_ready_csv[$check_num]=1
			fi
		fi
		let check_num=check_num+1
	done
	result=$(all_are_true "${is_ith_ready_csv[@]}")
done

echo "all files are downloaded"


