package util

IntString :: struct {
    string_map: map[int]string,
}

create_IntString :: proc() -> IntString {
    return IntString{
        string_map=make(map[int]string),
    }
}

IntString_set :: proc(self: ^IntString, id: int, s: string) {
    self.string_map[id] = s;
}

IntString_get_string :: proc(self: ^IntString, id: int) -> string {
    return self.string_map[id]
}
