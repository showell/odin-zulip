package html

import "core:encoding/entity"
import "core:fmt"
import "core:log"
import "core:strings"
import "../database"

Database :: database.Database

channel_row_html :: proc(db: Database, channel_index: int) -> string {
    channel_id := database.get_channel_id(db, channel_index)
    name := database.get_channel_name(db, channel_index)
    topic_count := database.get_num_topics_for_channel_index(db, channel_index);

    escaped_name, allocated_name := entity.escape_html(name)
    defer {
        if (allocated_name) {
            delete(escaped_name)
        }
    }

    return fmt.tprintf(`
<div class="channel_row">
  <div class="channel_name">%s</div>
  <div><a href="/topics/%d">topics</a></div>
  <div class="channel_count">%d topics</div>
</div>
`,
        escaped_name,
        channel_id,
        topic_count,
    )
}

channels_html :: proc(db: Database) -> string {
    lines := make([dynamic]string)
    defer delete(lines)

    channel_indexes := database.get_channel_indexes_by_name(db)
    defer delete(channel_indexes)

    heading := fmt.tprintf(`<h4>%d channels</h4>`, len(channel_indexes))
    append(&lines, heading)

    for channel_index in channel_indexes {
        append(&lines, channel_row_html(db, channel_index))
    }

    return strings.concatenate(lines[:])
}

topic_row_html :: proc(topic_row: database.TopicRow) -> string {
    escaped_name, allocated_name := entity.escape_html(topic_row.name)
    defer {
        if (allocated_name) {
            delete(escaped_name)
        }
    }

    return fmt.tprintf(`
<div class="topic_row">
  <div class="topic_name">%s</div>
  <div><a href="/topic_messages/%d">topics</a></div>
  <div class="topic_count">%d topics</div>
</div>
`,
        escaped_name,
        topic_row.address_index,
        topic_row.num_messages,
    )
}

topics_html :: proc(db: Database, channel_index: int) -> string {
    lines := make([dynamic]string)
    defer delete(lines)

    topic_rows := database.get_topic_rows_for_channel_index_by_name(db, channel_index)
    defer delete(topic_rows)

    channel_name := database.get_channel_name(db, channel_index)
    escaped_channel_name, allocated_name := entity.escape_html(channel_name)
    defer {
        if (allocated_name) {
            delete(escaped_channel_name)
        }
    }

    heading := fmt.tprintf(`<h4>%d topics for %s</h4>`, len(topic_rows), escaped_channel_name)
    append(&lines, heading)

    for topic_row in topic_rows {
        append(&lines, topic_row_html(topic_row))
    }

    return strings.concatenate(lines[:])
}

