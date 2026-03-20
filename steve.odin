package main

import "core:fmt"
import "core:log"
import "core:slice"
import "core:strings"
import "core:testing"

import "client"
import "database"
import "util"

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

    testing.expect_value(t, util.IntInt_size(&num_num), 4)
}

@(test)
test_InternString :: proc(t: ^testing.T) {
    intern_string := util.create_InternString()
    defer util.destroy_InternString(&intern_string)

    testing.expect_value(t, util.InternString_get_id(&intern_string, "one"), 1)
    testing.expect_value(t, util.InternString_get_id(&intern_string, "one"), 1)
    testing.expect_value(t, util.InternString_get_id(&intern_string, "two"), 2)
    testing.expect_value(t, util.InternString_get_id(&intern_string, "one"), 1)
    testing.expect_value(t, util.InternString_get_string(&intern_string, 1), "one")
    testing.expect_value(t, util.InternString_get_string(&intern_string, 2), "two")

    three := strings.clone("three")
    defer delete(three)

    testing.expect_value(t, util.InternString_get_id(&intern_string, three), 3)
    testing.expect_value(t, util.InternString_get_id(&intern_string, "one"), 1)
    testing.expect_value(t, util.InternString_get_id(&intern_string, three), 3)
    testing.expect_value(t, util.InternString_get_string(&intern_string, 3), "three")

    testing.expect_value(t, util.InternString_get_id(&intern_string, three), 3)
    testing.expect_value(t, util.InternString_get_id(&intern_string, "two"), 2)
}

@(test)
test_IntString :: proc(t: ^testing.T) {
    num_string := util.create_IntString()
    defer util.destroy_IntString(num_string)

    one := strings.clone("one")
    two := strings.clone("two")

    util.IntString_set(&num_string, 101, one)
    util.IntString_set(&num_string, 102, two)

    testing.expect(t, util.IntString_get_string(num_string, 101) == "one", "get 101")
    testing.expect(t, util.IntString_get_string(num_string, 102) == "two", "get 102")

    arr := util.IntString_id_array(num_string)
    defer delete(arr)
    slice.sort(arr[:])
    testing.expect(t, slice.equal(arr[:], []int{101, 102}), "id_array")
}

@(test)
test_IntIntInt :: proc(t: ^testing.T) {
    int_int_int := util.create_IntIntInt()
    defer util.destroy_IntIntInt(&int_int_int)

    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 101, 101), 1)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 102, 101), 2)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 103, 101), 3)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 101, 101), 1)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 101, 101), 1)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 102, 101), 2)
    testing.expect_value(t, util.IntIntInt_get_id(&int_int_int, 101, 104), 4)

    testing.expect_value(t, util.IntIntInt_get_id2(&int_int_int, 1), 101)
    testing.expect_value(t, util.IntIntInt_get_id2(&int_int_int, 2), 101)
    testing.expect_value(t, util.IntIntInt_get_id2(&int_int_int, 3), 101)
    testing.expect_value(t, util.IntIntInt_get_id2(&int_int_int, 4), 104)

    {
        arr := util.IntIntInt_get_ids_from_id1(&int_int_int, 101)
        defer delete(arr)
        slice.sort(arr[:])
        testing.expect(t, slice.equal(arr[:], []int{1, 4}), "ids from id1")
    }
    {
        arr := util.IntIntInt_get_ids_from_id1(&int_int_int, 102)
        defer delete(arr)
        slice.sort(arr[:])
        testing.expect(t, slice.equal(arr[:], []int{2}), "ids from id1")
    }

    testing.expect_value(t, util.IntIntInt_get_id2_count(&int_int_int, 101), 2)
    testing.expect_value(t, util.IntIntInt_get_id2_count(&int_int_int, 102), 1)
    testing.expect_value(t, util.IntIntInt_get_id2_count(&int_int_int, 103), 1)
    testing.expect_value(t, util.IntIntInt_get_id2_count(&int_int_int, 99), 0)
}

@(test)
test_Database :: proc(t: ^testing.T) {
    db := database.create()
    defer database.destroy(&db)

    engineering := client.ServerSubscription{
        stream_id = 103,
        name = strings.clone("engineering"),
    }

    feedback := client.ServerSubscription{
        stream_id = 101,
        name = strings.clone("feedback"),
    }

    design := client.ServerSubscription{
        stream_id = 102,
        name = strings.clone("design"),
    }

    database.process_server_subscription(&db, engineering)
    database.process_server_subscription(&db, feedback)
    database.process_server_subscription(&db, design)

    {
        arr := database.get_channel_ids_by_name(db)
        defer delete(arr)
        testing.expect(t, slice.equal(arr[:], []int{102, 103, 101}), "channel ids")
    }

    testing.expect_value(t, database.get_channel_name(db, 101), "feedback")
    testing.expect_value(t, database.get_channel_name(db, 102), "design")
    testing.expect_value(t, database.get_channel_name(db, 103), "engineering")
    testing.expect_value(t, database.get_channel_name(db, 99), "")
}
