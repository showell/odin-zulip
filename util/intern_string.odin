package util

import "core:strings"

InternString :: struct {
    string_map: map[int]string,
    id_map: map[string]int,
    seq: int,
}

create_InternString :: proc() -> InternString {
    return InternString{
        string_map=make(map[int]string),
        id_map=make(map[string]int),
        seq=0,
    }
}

destroy_InternString :: proc(self: InternString) {
    for id in self.string_map {
        delete(self.string_map[id])
    }
    delete(self.string_map)
    delete(self.id_map)
}

InternString_get_id :: proc(self: ^InternString, s: string) -> int {
    if s in self.id_map {
        return self.id_map[s]
    }
    self.seq += 1
    id := self.seq
    new_s := strings.clone(s)
    self.string_map[id] = new_s
    self.id_map[new_s] = id
    return id
}

InternString_get_string :: proc(self: InternString, id: int) -> string {
    return self.string_map[id]
}
