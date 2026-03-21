package database

import "core:slice"

import "../client"

ChannelRow :: struct {
    index: int,
    id: int,
    name: string,
}

Database :: struct {
    channel_rows: [dynamic]ChannelRow,
}

create :: proc() -> Database {
    return Database{
        channel_rows = make([dynamic]ChannelRow),
    }
}

destroy :: proc(db: ^Database) {
    delete(db.channel_rows)
}

process_server_subscription :: proc(
    db: ^Database,
    subscription: client.ServerSubscription,
) {
    index := len(db.channel_rows)

    channel_row := ChannelRow{
        index = index,
        id = subscription.stream_id,
        name = subscription.name,
    }

    append(&db.channel_rows, channel_row)
}

/*
process_server_message :: proc(
    db: ^Database,
    server_message: client.ServerMessage,
) {
    message_id := server_message.id
    channel_id := server_message.stream_id
    sender_id := server_message.sender_id
    user_id := sender_id

    full_name := server_message.sender_full_name
    topic_name := server_message.subject
    content := server_message.content
    // TODO: call fix_content

    angry_dog_content_id := util.InternString_get_id(
        &db.content_string,
        content,
    )
    angry_dog_topic_id := util.InternString_get_id(
        &db.topic_name,
        topic_name,
    )

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
}
*/

get_channel_name :: proc(db: Database, channel_id: int) -> string {
    return "foo";
}

get_channel_indexes_by_name :: proc(db: Database) -> []int {
    row_arr: []ChannelRow = db.channel_rows[:]

    slice.sort_by(row_arr, proc(row1, row2: ChannelRow) -> bool {
        return row1.name < row2.name
    })

    arr := make([]int, len(row_arr))

    for row, i in row_arr {
        arr[i] = row.index
    }

    return arr
}
