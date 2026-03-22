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
    index_engineering := 0

    feedback := client.ServerSubscription{
        stream_id = 101,
        name = "feedback",
    }
    index_feedback := 1

    design := client.ServerSubscription{
        stream_id = 102,
        name = "design",
    }
    index_design := 2

    database.process_server_subscription(&db, engineering)
    database.process_server_subscription(&db, feedback)
    database.process_server_subscription(&db, design)

    {
        arr := database.get_channel_indexes_by_name(db)
        defer delete(arr)
        testing.expect(
            t,
            slice.equal(
                arr[:],
                []int{index_design, index_engineering, index_feedback},
            ),
            "channel ids",
        )
    }

    testing.expect_value(t, database.get_channel_index(db, 103), index_engineering)
    testing.expect_value(t, database.get_channel_index(db, 101), index_feedback)
    testing.expect_value(t, database.get_channel_index(db, 102), index_design)

    testing.expect_value(t, database.get_channel_name(db, 0), "engineering")
    testing.expect_value(t, database.get_channel_name(db, 1), "feedback")
    testing.expect_value(t, database.get_channel_name(db, 2), "design")

    testing.expect_value(t, database.get_channel_id(db, 0), 103)
    testing.expect_value(t, database.get_channel_id(db, 1), 101)
    testing.expect_value(t, database.get_channel_id(db, 2), 102)

    testing.expect_value(t, database.get_num_topics_for_channel_index(db, 0), 0)
    testing.expect_value(t, database.get_num_topics_for_channel_index(db, 1), 0)
    testing.expect_value(t, database.get_num_topics_for_channel_index(db, 2), 0)

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

    testing.expect_value(t, database.get_sender_name_for_sender_index(db, 0), "Foo Barson")
    testing.expect_value(t, database.get_sender_name_for_sender_index(db, 1), "Fred Flintstone")

    testing.expect_value(t, database.get_num_topics_for_channel_index(db, index_design), 2)
    testing.expect_value(t, database.get_num_topics_for_channel_index(db, index_engineering), 0)
    testing.expect_value(t, database.get_num_topics_for_channel_index(db, index_feedback), 1)

    TopicRow :: database.TopicRow

    {
        topic_rows := database.get_topic_rows_for_channel_index_by_name(db, index_design)
        defer delete(topic_rows)

        expected_topic_rows := []TopicRow{
            TopicRow{
                address_index = 2,
                name = "another design topic",
                topic_index = 2,
                num_messages = 1,
            },
            TopicRow{
                address_index = 0,
                name = "design stuff",
                topic_index = 0,
                num_messages = 2,
            },
        }

        testing.expect(
            t,
            slice.equal(
                topic_rows[:],
                expected_topic_rows,
            ),
            "topic rows for design",
        )
    }

    {
        message_rows := database.message_rows_for_address_index(db, 0)
        defer delete(message_rows)

        log.info(message_rows)

        testing.expect_value(t, len(message_rows), 2)

        testing.expect_value(t, message_rows[0].content, "message1")
        testing.expect_value(t, message_rows[1].content, "message2")
    }
}
