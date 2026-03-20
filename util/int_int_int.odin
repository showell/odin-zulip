package util

IntPair :: struct {
    id1: int,
    id2: int,
    seq: int,
}

IntIntInt :: struct {
    fwd_map: map[IntPair]int,
    reverse_map: map[int]IntPair,
    seq: int,
}

create_IntIntInt :: proc() -> IntIntInt {
    return IntIntInt{
        fwd_map=make(map[IntPair]int),
        reverse_map=make(map[int]IntPair),
        seq=0,
    }
}

destroy_IntIntInt :: proc(self: ^IntIntInt) {
    delete(self.fwd_map)
    delete(self.reverse_map)
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

    return id
}

IntIntInt_get_id2 :: proc(self: ^IntIntInt, id: int) -> int {
    return self.reverse_map[id].id2
}
