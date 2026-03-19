package util

IntString :: struct {
    string_map: map[int]string,
}

create_IntString :: proc() -> IntString {
    return IntString{
        string_map=make(map[int]string),
    }
}

destroy_IntString :: proc(self: ^IntString) {
    delete(self.string_map);
}

IntString_set :: proc(self: ^IntString, id: int, s: string) {
    self.string_map[id] = s;
}

IntString_get_string :: proc(self: ^IntString, id: int) -> string {
    return self.string_map[id]
}

IntString_id_array :: proc(self: ^IntString) -> [dynamic]int {
    arr: [dynamic]int

    for num in self.string_map {
        append(&arr, num)
    }
    return arr
}
