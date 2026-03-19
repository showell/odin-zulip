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

    reverse_sort :: proc(num_num: ^util.IntInt, id: int) -> [dynamic]int {
        arr := util.IntInt_reverse_get(num_num, id)
        slice.sort(arr[:])
        return arr
    }

    {
        arr := reverse_sort(&num_num, 50)
        defer delete(arr)
        testing.expect(t, slice.equal(arr[:], []int{5, 7, 8}), "reverse 50")
    }

    {
        arr := reverse_sort(&num_num, 150)
        defer delete(arr)
        testing.expect(t, slice.equal(arr[:], []int{6}), "reverse 50")
    }

    {
        arr := reverse_sort(&num_num, 99)
        defer delete(arr)
        testing.expect(t, slice.equal(arr[:], []int{}), "reverse 99")
    }

    testing.expect_value(t, util.IntInt_size(&num_num), 4);
}

@(test)
test_IntString :: proc(t: ^testing.T) {
    num_string := util.create_IntString()
    defer util.destroy_IntString(&num_string)

    util.IntString_set(&num_string, 101, "one")
    util.IntString_set(&num_string, 102, "two")

    testing.expect(t, util.IntString_get_string(&num_string, 101) == "one", "get 101")
    testing.expect(t, util.IntString_get_string(&num_string, 102) == "two", "get 102")

    arr := util.IntString_id_array(&num_string)
    defer delete(arr)
    slice.sort(arr[:])
    testing.expect(t, slice.equal(arr[:], []int{101, 102}), "id_array")
}
