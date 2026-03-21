package util

IntSet :: map[int]struct{}

IntInt :: struct {
    fwd_map: map[int]int,
    reverse_map: map[int]IntSet,
}

create_IntInt :: proc() -> IntInt {
    return IntInt{
        fwd_map=make(map[int]int),
        reverse_map=make(map[int]IntSet),
    }
}

destroy_IntInt :: proc(self: IntInt) {
    delete(self.fwd_map)

    for _, &int_set in self.reverse_map {
        delete(int_set)
    }

    delete(self.reverse_map)
}

IntInt_size :: proc(self: IntInt) -> int {
    return len(self.fwd_map)
}

IntInt_set :: proc(self: ^IntInt, id1: int, id2: int) {
    self.fwd_map[id1] = id2

    reverse_set: IntSet = self.reverse_map[id2] or_else make(IntSet)
    reverse_set[id1] = struct{}{}
    self.reverse_map[id2] = reverse_set
}

IntInt_get :: proc(self: IntInt, id1: int) -> int {
    return self.fwd_map[id1]
}

IntInt_reverse_get :: proc(self: IntInt, id2: int) -> [dynamic]int {
    set := self.reverse_map[id2]
    arr: [dynamic]int

    for num in set {
        append(&arr, num)
    }

    return arr
}

