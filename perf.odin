package main

import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:slice"
import "core:strings"
import "core:testing"

import "client"
import "database"
import "html"

test_html_for_channel :: proc(db: database.Database, channel_index: int) {
    s := html.topics_html(db, channel_index)
    defer delete(s)

    topic_rows := database.get_topic_rows_for_channel_index_by_name(db, channel_index)
    defer delete(topic_rows)

    for topic_row in topic_rows {
        s := html.messages_html(db, topic_row.address_index)
        delete(s)
    }
}

test_html :: proc(db: database.Database) {
    s := html.channels_html(db)
    defer delete(s)

    channel_indexes := database.get_channel_indexes_by_name(db)
    defer delete(channel_indexes)

    for channel_index in channel_indexes {
        test_html_for_channel(db, channel_index)
    }
    log.info(fmt.tprintf("output %d messages", len(db.message_arr)))
}

@(test)
test_database :: proc(t: ^testing.T) {
    db := database.create()
    defer database.destroy(&db)

    nums := make([dynamic]int)
    defer delete(nums)

    for i in 0..<20 {
        append(&nums, i)
    }

    rand.shuffle(nums[:])

    message_id := 10000

    for n in nums {
        channel_id := 100 + n
        name := fmt.tprintf("channel_%d", channel_id)

        subscription := client.ServerSubscription{
            stream_id = channel_id,
            name = name,
        }
        database.process_server_subscription(&db, subscription)
    }

    for i in 1..=2500 {
        for n in nums {
            channel_id := 100 + n

            for topic_n in nums {
                subject := fmt.tprintf("topic_%d", 1000 + topic_n)
                message_id += 1
                message := client.ServerMessage{
                    content = fmt.tprintf("content %d", message_id),
                    id = message_id,
                    sender_full_name = "Foo Barson",
                    sender_id = 1001,
                    subject = subject,
                    stream_id = channel_id,
                }
                database.process_server_message(&db, message)
            }
        }
        log.info(fmt.tprintf("%d messages", len(db.message_arr)))
    }


    for i in 1..=10 {
        test_html(db)
    }
}
