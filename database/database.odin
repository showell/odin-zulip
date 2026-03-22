package database

import "core:log"
import "core:slice"

import "../client"

IndexSet :: map[int]bool

AddressRow :: struct {
    channel_index: int,
    topic_index: int,
}

ChannelRow :: struct {
    index: int,
    id: int,
    name: string,
}

MessageRow :: struct {
    message_id: int,
    sender_index: int,
    content: string,
    address_index: int,
}

TopicRow :: struct {
    index: int,
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

    address_arr: [dynamic]AddressRow,
    address_to_index_map: map[AddressRow]int,

    user_arr: [dynamic]UserRow,
    user_id_index_map: map[int]int,

    message_arr: [dynamic]MessageRow,

    address_index_to_message_index_set: map[int]IndexSet,

    channel_index_to_topic_index_set: map[int]IndexSet,
}

create :: proc() -> Database {
    return Database{
        channel_rows = make([dynamic]ChannelRow),
        channel_id_index_map = make(map[int]int),

        topic_string_arr = make([dynamic]string),
        topic_string_index_map = make(map[string]int),

        address_arr = make([dynamic]AddressRow),
        address_to_index_map = make(map[AddressRow]int),

        user_arr = make([dynamic]UserRow),
        user_id_index_map = make(map[int]int),

        message_arr = make([dynamic]MessageRow),

        address_index_to_message_index_set = make(map[int]IndexSet),
        channel_index_to_topic_index_set = make(map[int]IndexSet),
    }
}

destroy :: proc(db: ^Database) {
    delete(db.channel_rows)
    delete(db.channel_id_index_map)

    delete(db.topic_string_arr)
    delete(db.topic_string_index_map)

    delete(db.address_arr)
    delete(db.address_to_index_map)

    delete(db.user_arr)
    delete(db.user_id_index_map)

    delete(db.message_arr)

    for _, message_index_set in db.address_index_to_message_index_set {
        delete(message_index_set)
    }

    delete(db.address_index_to_message_index_set)

    for _, topic_index_set in db.channel_index_to_topic_index_set {
        delete(topic_index_set)
    }

    delete(db.channel_index_to_topic_index_set)
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
    message_id := server_message.id
    channel_id := server_message.stream_id
    sender_id := server_message.sender_id

    user_name := server_message.sender_full_name
    topic_name := server_message.subject
    content := server_message.content
    // TODO: call fix_content

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

    if !(channel_id in db.channel_id_index_map) {
        log.error("could not find channel")
    }

    channel_index := db.channel_id_index_map[channel_id]

    topic_index := get_or_make_index_for_string(
        &db.topic_string_arr,
        &db.topic_string_index_map,
        topic_name,
    )

    address := AddressRow{
        channel_index = channel_index,
        topic_index = topic_index,
    }

    address_index: int

    if address in db.address_to_index_map {
        address_index = db.address_to_index_map[address]
    } else {
        address_index = len(db.address_arr)
        append(&db.address_arr, address)
        db.address_to_index_map[address] = address_index
    }

    message_index := len(db.message_arr)

    message := MessageRow{
        message_id = message_id,
        sender_index = user_index,
        content = content,
        address_index = address_index,
    }

    append(&db.message_arr, message)

    // ADDRESS -> list of MESSAGE
    message_index_set: IndexSet

    if (address_index in db.address_index_to_message_index_set) {
        message_index_set = db.address_index_to_message_index_set[address_index]
    } else {
        message_index_set = make(map[int]bool)
    }

    message_index_set[message_index] = true
    db.address_index_to_message_index_set[address_index] = message_index_set

    // CHANNEL -> list of TOPIC
    topic_index_set: IndexSet

    if (channel_index in db.channel_index_to_topic_index_set) {
        topic_index_set = db.channel_index_to_topic_index_set[channel_index]
    } else {
        topic_index_set = make(map[int]bool)
    }

    topic_index_set[topic_index] = true
    db.channel_index_to_topic_index_set[channel_index] = topic_index_set
}

get_channel_index :: proc(db: Database, channel_id: int) -> int {
    return db.channel_id_index_map[channel_id]
}

get_channel_id :: proc(db: Database, channel_index: int) -> int {
    return db.channel_rows[channel_index].id
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

get_num_topics_for_channel_index :: proc(db: Database, channel_index: int) -> int {
    if !(channel_index in db.channel_index_to_topic_index_set) {
        return 0
    }
    return len(db.channel_index_to_topic_index_set[channel_index])
}

get_topic_rows_for_channel_index_by_name :: proc(
    db: Database,
    channel_index: int,
) -> [dynamic]TopicRow {
    if !(channel_index in db.channel_index_to_topic_index_set) {
        return make([dynamic]TopicRow, 0)
    }

    topic_index_set := db.channel_index_to_topic_index_set[channel_index]

    row_arr: [dynamic]TopicRow = make([dynamic]TopicRow)

    for topic_index, i in topic_index_set {
        if !topic_index_set[topic_index] {
            log.error("unexpected")
            continue
        }

        topic_name := db.topic_string_arr[topic_index]

        topic_row := TopicRow{
            index = topic_index,
            name = topic_name,
        }

        append(&row_arr, topic_row)
    }

    slice.sort_by(row_arr[:], proc(row1, row2: TopicRow) -> bool {
        return row1.name < row2.name
    })

    return row_arr
}
