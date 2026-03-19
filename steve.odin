package main

import "core:fmt"

IntInt :: struct {
    fwd_map: map[int]int
}

create_IntInt :: proc() -> IntInt {
    my_fwd_map := make(map[int]int);

    int_int := IntInt{fwd_map=my_fwd_map}
    return int_int;
}

IntInt_set :: proc(self: ^IntInt, k: int, v: int) {
    self.fwd_map[k] = v;
}

IntInt_get :: proc(self: ^IntInt, k: int) -> int {
    return self.fwd_map[k];
}

main :: proc() {
    num_num := create_IntInt();

    IntInt_set(&num_num, 5, 50);

	fmt.printf("%d\n", IntInt_get(&num_num, 5));
}
