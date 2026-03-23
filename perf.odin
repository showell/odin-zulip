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

    for i in 0..<20 {
        append(&nums, i)
    }

    rand.shuffle(nums[:])

    for n in nums {
        channel_id := 100 + n
        name := fmt.tprintf("channel_%d", channel_id)

        subscription := client.ServerSubscription{
            stream_id = channel_id,
            name = name,
        }
        database.process_server_subscription(&db, subscription)
    }
}
