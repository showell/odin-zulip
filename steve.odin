package main

import "core:fmt"
import "core:log"
import "core:slice"
import "core:strings"
import "core:testing"

import "client"
import "database"

@(test)
test_Database :: proc(t: ^testing.T) {
    db := database.create()
    defer database.destroy(&db)

    engineering := client.ServerSubscription{
        stream_id = 103,
        name = "engineering",
    }

    feedback := client.ServerSubscription{
        stream_id = 101,
        name = "feedback",
    }

    design := client.ServerSubscription{
        stream_id = 102,
        name = "design",
    }

    database.process_server_subscription(&db, engineering)
    database.process_server_subscription(&db, feedback)
    database.process_server_subscription(&db, design)

    {
        arr := database.get_channel_indexes_by_name(db)
        defer delete(arr)
        testing.expect(t, slice.equal(arr[:], []int{2, 0, 1}), "channel ids")
    }

    testing.expect_value(t, database.get_channel_name(db, 2), "design")
    testing.expect_value(t, database.get_channel_name(db, 0), "engineering")
    testing.expect_value(t, database.get_channel_name(db, 1), "feedback")

    message1 := client.ServerMessage{
        content = "message1",
        id = 201,
        sender_full_name = "Foo Barson",
        sender_id = 1001,
        subject = "design stuff",
        stream_id = 102,
    }

    message2 := client.ServerMessage{
        content = "message2",
        id = 202,
        sender_full_name = "Foo Barson",
        sender_id = 1001,
        subject = "design stuff",
        stream_id = 102,
    }

    message3 := client.ServerMessage{
        content = "message3",
        id = 203,
        sender_full_name = "Fred Flintstone",
        sender_id = 1002,
        subject = "feedback stuff",
        stream_id = 101,
    }

    message4 := client.ServerMessage{
        content = "message4",
        id = 204,
        sender_full_name = "Fred Flintstone",
        sender_id = 1002,
        subject = "another design topic",
        stream_id = 102,
    }

    database.process_server_message(&db, message1)
    database.process_server_message(&db, message2)
    database.process_server_message(&db, message3)
    database.process_server_message(&db, message4)

    /*

    testing.expect_value(t, database.get_topic_count_for_channel(db, 101), 1)
    testing.expect_value(t, database.get_topic_count_for_channel(db, 102), 2)
    testing.expect_value(t, database.get_topic_count_for_channel(db, 103), 0)
    */
}
