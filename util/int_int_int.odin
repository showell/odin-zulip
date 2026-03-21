package util

import "core:log"

// IntSet is in int_int.odin

IntPair :: struct {
    id1: int,
    id2: int,
}

IntIntInt :: struct {
    fwd_map: map[IntPair]int,
    reverse_map: map[int]IntPair,
    ids_from_id1: map[int]IntSet,
    id2_from_id1: map[int]IntSet,
    seq: int,
}

create_IntIntInt :: proc() -> IntIntInt {
    return IntIntInt{
        fwd_map=make(map[IntPair]int),
        reverse_map=make(map[int]IntPair),
        ids_from_id1=make(map[int]IntSet),
        id2_from_id1=make(map[int]IntSet),
        seq=0,
    }
}

destroy_IntIntInt :: proc(self: IntIntInt) {
    delete(self.fwd_map)
    delete(self.reverse_map)

    for _, set in self.ids_from_id1 {
        delete(set)
    }
    delete(self.ids_from_id1)

    for _, set in self.id2_from_id1 {
        delete(set)
    }
    delete(self.id2_from_id1)
}

IntIntInt_get_id :: proc(self: ^IntIntInt, id1: int, id2: int) -> int {
    pair := IntPair{ id1=id1, id2=id2 }
    if pair in self.fwd_map {
        return self.fwd_map[pair]
    }

    self.seq += 1
    id := self.seq

    self.fwd_map[pair] = id
    self.reverse_map[id] = pair

    {
        set: IntSet = self.ids_from_id1[id1] or_else make(IntSet)
        set[id] = struct{}{}
        self.ids_from_id1[id1] = set
    }

    {
        set: IntSet = self.id2_from_id1[id1] or_else make(IntSet)
        set[id2] = struct{}{}
        self.id2_from_id1[id1] = set
    }

    return id
}

IntIntInt_get_id2_count :: proc(self: IntIntInt, id1: int) -> int {
    return len(self.id2_from_id1[id1])
}

IntIntInt_get_id2 :: proc(self: IntIntInt, id: int) -> int {
    return self.reverse_map[id].id2
}

IntIntInt_get_ids_from_id1 :: proc(self: IntIntInt, id1: int) -> [dynamic]int {
    arr: [dynamic]int

    for id in self.ids_from_id1[id1] {
        append(&arr, id)
    }

    return arr
}
