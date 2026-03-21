package database

import "core:slice"

import "../client"

ChannelRow :: struct {
    index: int,
    id: int,
    name: string,
}

UserRow :: struct {
    id: int,
    name: string,
}

Database :: struct {
    channel_rows: [dynamic]ChannelRow,
    channel_id_index_map: map[int]int,

    topic_string_arr: [dynamic]string,
    topic_string_index_map: map[string]int,

    user_arr: [dynamic]UserRow,
    user_id_index_map: map[int]int,
}

create :: proc() -> Database {
    return Database{
        channel_rows = make([dynamic]ChannelRow),
        channel_id_index_map = make(map[int]int),

        topic_string_arr = make([dynamic]string),
        topic_string_index_map = make(map[string]int),

        user_arr = make([dynamic]UserRow),
        user_id_index_map = make(map[int]int),
    }
}

destroy :: proc(db: ^Database) {
    delete(db.channel_rows)
    delete(db.channel_id_index_map)

    delete(db.topic_string_arr)
    delete(db.topic_string_index_map)

    delete(db.user_arr)
    delete(db.user_id_index_map)
}

process_server_subscription :: proc(
    db: ^Database,
    subscription: client.ServerSubscription,
) {
    index := len(db.channel_rows)
    id := subscription.stream_id

    channel_row := ChannelRow{
        index = index,
        id = id,
        name = subscription.name,
    }

    append(&db.channel_rows, channel_row)

    db.channel_id_index_map[id] = index
}

get_or_make_index_for_string :: proc(
    string_array: ^[dynamic]string,
    string_index_map: ^map[string]int,
    str: string,
) -> int {
    if str in string_index_map {
        return string_index_map[str]
    }

    index := len(string_array)
    append(string_array, str)
    string_index_map[str] = index
    return index
}

process_server_message :: proc(
    db: ^Database,
    server_message: client.ServerMessage,
) {
    /*
    message_id := server_message.id
    channel_id := server_message.stream_id
    */
    sender_id := server_message.sender_id

    user_name := server_message.sender_full_name
    topic_name := server_message.subject
    content := server_message.content
    // TODO: call fix_content

    topic_index := get_or_make_index_for_string(
        &db.topic_string_arr,
        &db.topic_string_index_map,
        topic_name,
    )

    user_index: int

    if (sender_id in db.user_id_index_map) {
        user_index = db.user_id_index_map[sender_id]
    } else {
        user_index = len(db.user_arr)

        user := UserRow{
            id = sender_id,
            name = user_name,
        }
        append(&db.user_arr, user)
        db.user_id_index_map[sender_id] = user_index
    }

    /*
    angry_dog_channel_topic_id := util.IntIntInt_get_id(
        &db.channel_topic,
        channel_id,
        angry_dog_topic_id,
    )

    util.IntInt_set(&db.message_sender, message_id, sender_id)
    util.IntInt_set(&db.message_channel, message_id, channel_id)
    util.IntInt_set(
        &db.message_to_channel_topic,
        message_id,
        angry_dog_channel_topic_id,
    )
    util.IntInt_set(&db.message_content, message_id, angry_dog_content_id)

    util.IntString_set(&db.user_full_name, user_id, full_name)
    */
}

get_channel_name :: proc(db: Database, channel_index: int) -> string {
    return db.channel_rows[channel_index].name
}

get_channel_indexes_by_name :: proc(db: Database) -> []int {
    row_arr: [dynamic]ChannelRow = make(
        [dynamic]ChannelRow,
        len(db.channel_rows),
    )
    defer delete(row_arr)

    for row, i in db.channel_rows {
        row_arr[i] = row
    }

    slice.sort_by(row_arr[:], proc(row1, row2: ChannelRow) -> bool {
        return row1.name < row2.name
    })

    arr := make([]int, len(row_arr))

    for row, i in row_arr {
        arr[i] = row.index
    }

    return arr
}
