package database

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
