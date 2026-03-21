package util

import "core:slice"
import "core:strings"

IntString :: struct {
    string_map: map[int]string,
}

create_IntString :: proc() -> IntString {
    return IntString{
        string_map=make(map[int]string),
    }
}

destroy_IntString :: proc(self: IntString) {
    for id in self.string_map {
        delete(self.string_map[id])
    }
    delete(self.string_map);
}

IntString_set :: proc(self: ^IntString, id: int, s: string) {
    if (id in self.string_map) {
        return
    }
    self.string_map[id] = strings.clone(s);
}

IntString_get_string :: proc(self: IntString, id: int) -> string {
    return self.string_map[id]
}

IdStr :: struct {
    id: int,
    str: string,
}

IntString_sorted_id_str_array :: proc(self: IntString) -> []IdStr {
    arr: []IdStr = make([]IdStr, len(self.string_map))

    i := 0
    for id, str in self.string_map {
        arr[i] = { id=id, str=str }
        i += 1
    }

    slice.sort_by(arr[:], proc(struct1, struct2: IdStr) -> bool {
        return struct1.str < struct2.str
    })

    return arr
}
