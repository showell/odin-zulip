package main

import "core:fmt"

IntSet :: map[int]struct{}

IntInt :: struct {
    fwd_map: map[int]int,
    reverse_map: map[int]IntSet,
}

create_IntInt :: proc() -> IntInt {
    return IntInt{
        fwd_map=make(map[int]int),
        reverse_map=make(map[int]IntSet),
    };
}

IntInt_set :: proc(self: ^IntInt, id1: int, id2: int) {
    self.fwd_map[id1] = id2;

    reverse_set: IntSet
    if id2 in self.reverse_map {
        reverse_set = self.reverse_map[id2]
    } else {
        reverse_set = make(IntSet)
    }
    reverse_set[id1] = struct{}{}
    self.reverse_map[id2] = reverse_set
}

IntInt_get :: proc(self: ^IntInt, id1: int) -> int {
    return self.fwd_map[id1]
}

IntInt_reverse_get :: proc(self: ^IntInt, id2: int) -> [dynamic]int {
    set := self.reverse_map[id2];
    arr: [dynamic]int

    for num in set {
        append(&arr, num)
    }

    return arr
}

main :: proc() {
    num_num := create_IntInt();

    IntInt_set(&num_num, 5, 50)
    IntInt_set(&num_num, 6, 150)
    IntInt_set(&num_num, 7, 50)

	fmt.printf("%d\n", IntInt_get(&num_num, 5))
	fmt.printf("%v\n", IntInt_reverse_get(&num_num, 50))
	fmt.printf("%v\n", IntInt_reverse_get(&num_num, 150))
	fmt.printf("%v\n", IntInt_reverse_get(&num_num, 180))
}
