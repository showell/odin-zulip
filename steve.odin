package main

import "core:fmt"

import "util"
import "core:log"
import "core:slice"
import "core:testing"

@(test)
test_IntInt :: proc(t: ^testing.T) {
    num_num := util.create_IntInt()
    defer util.destroy_IntInt(&num_num)

    util.IntInt_set(&num_num, 5, 50)
    util.IntInt_set(&num_num, 6, 150)
    util.IntInt_set(&num_num, 7, 50)
    util.IntInt_set(&num_num, 8, 50)

    testing.expect(t, util.IntInt_get(&num_num, 5) == 50, "get 5")
    testing.expect(t, util.IntInt_get(&num_num, 6) == 150, "get 6")
    testing.expect(t, util.IntInt_get(&num_num, 7) == 50, "get 7")
    testing.expect(t, util.IntInt_get(&num_num, 8) == 50, "get 8")

    sorted :: proc(num_num: ^util.IntInt, id: int) -> [dynamic]int {
        arr := util.IntInt_reverse_get(num_num, 50)
        slice.sort(arr[:])
        return arr
    }

    arr := sorted(&num_num, 50)
    defer delete(arr)
    testing.expect(t, slice.equal(arr[:], []int{5, 7, 8}), "reverse 50")

    /*
	fmt.printf("%v\n", util.IntInt_reverse_get(&num_num, 150))
	fmt.printf("%v\n", util.IntInt_reverse_get(&num_num, 180))
    */
}

@(test)
test_IntString :: proc(t: ^testing.T) {
    num_string := util.create_IntString()

    util.IntString_set(&num_string, 101, "one")
    util.IntString_set(&num_string, 102, "two")

    testing.expect(t, util.IntString_get_string(&num_string, 101) == "one", "get 101")
    testing.expect(t, util.IntString_get_string(&num_string, 102) == "two", "get 102")

    util.destroy_IntString(&num_string)
}
