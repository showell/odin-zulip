package database

import "core:slice"

import "../client"
import "../util"

Database :: struct {
    message_sender: util.IntInt,
    message_channel: util.IntInt,
    message_to_channel_topic: util.IntInt,
    message_content: util.IntInt,

    channel_name: util.IntString,
    user_full_name: util.IntString,

    topic_name: util.InternString,
    content_string: util.InternString,

    channel_topic: util.IntIntInt,
}

create :: proc() -> Database {
    return Database{
        message_sender = util.create_IntInt(),
        message_channel = util.create_IntInt(),
        message_to_channel_topic = util.create_IntInt(),
        message_content = util.create_IntInt(),

        channel_name = util.create_IntString(),
        user_full_name = util.create_IntString(),

        topic_name = util.create_InternString(),
        content_string = util.create_InternString(),

        channel_topic = util.create_IntIntInt(),
    }
}

destroy :: proc(db: ^Database) {
    util.destroy_IntInt(db.message_sender)
    util.destroy_IntInt(db.message_channel)
    util.destroy_IntInt(db.message_to_channel_topic)
    util.destroy_IntInt(db.message_content)

    util.destroy_IntString(db.channel_name)
    util.destroy_IntString(db.user_full_name)

    util.destroy_InternString(db.topic_name)
    util.destroy_InternString(db.content_string)

    util.destroy_IntIntInt(db.channel_topic)
}

process_server_subscription :: proc(
    db: ^Database,
    subscription: client.ServerSubscription,
) {
    util.IntString_set(
        &db.channel_name,
        subscription.stream_id,
        subscription.name,
    )
}

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

get_channel_name :: proc(db: Database, channel_id: int) -> string {
    return util.IntString_get_string(db.channel_name, channel_id)
}

get_channel_ids_by_name :: proc(db: Database) -> [dynamic]int {
    arr := util.IntString_id_array(db.channel_name)

    cmp :: proc(id1, id2: int, user_data: rawptr) -> bool {
        channel_name := (^util.IntString)(user_data)
        name1 := util.IntString_get_string(channel_name^, id1)
        name2 := util.IntString_get_string(channel_name^, id2)
        return name1 < name2
    }

    channel_name_copy := db.channel_name
    slice.sort_by_with_data(arr[:], cmp, &channel_name_copy)

    return arr
}
