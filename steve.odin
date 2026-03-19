package main

import "core:fmt"

import "util"

test_IntInt :: proc() {
    num_num := util.create_IntInt();

    util.IntInt_set(&num_num, 5, 50)
    util.IntInt_set(&num_num, 6, 150)
    util.IntInt_set(&num_num, 7, 50)
    util.IntInt_set(&num_num, 8, 50)

	fmt.printf("%d\n", util.IntInt_get(&num_num, 5))
	fmt.printf("%d\n", util.IntInt_get(&num_num, 6))
	fmt.printf("%d\n", util.IntInt_get(&num_num, 7))
	fmt.printf("%d\n", util.IntInt_get(&num_num, 8))
	fmt.printf("%v\n", util.IntInt_reverse_get(&num_num, 50))
	fmt.printf("%v\n", util.IntInt_reverse_get(&num_num, 150))
	fmt.printf("%v\n", util.IntInt_reverse_get(&num_num, 180))
}

main :: proc() {
    test_IntInt()
}
