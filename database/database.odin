package database

import "core:slice"

import "../client"
import "../util"

Database :: struct {
    channel_name: util.IntString,
}

create :: proc() -> Database {
    return Database{
        channel_name = util.create_IntString(),
    }
}

destroy :: proc(db: ^Database) {
    util.destroy_IntString(&db.channel_name)
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

get_channel_name :: proc(db: ^Database, channel_id: int) -> string {
    return util.IntString_get_string(&db.channel_name, channel_id)
}

channel_ids_by_name :: proc(db: ^Database) -> [dynamic]int {
    arr := util.IntString_id_array(&db.channel_name)

    cmp :: proc(id1, id2: int, user_data: rawptr) -> bool {
        db := (^Database)(user_data)
        return get_channel_name(db, id1) < get_channel_name(db, id2)
    }

    slice.sort_by_with_data(arr[:], cmp, db)

    return arr
}
