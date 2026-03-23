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

@(test)
test_Database :: proc(t: ^testing.T) {
    db := database.create()
    defer database.destroy(&db)

    nums := make([dynamic]int)
    defer delete(nums)

    for i in 0..<200 {
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

        for _ in 1..=200 {
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
    }
    log.info(fmt.tprintf("%d messages", len(db.message_arr)))
}
