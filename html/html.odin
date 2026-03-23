package html

import "core:fmt"
import "core:strings"
import "../database"

Database :: database.Database

channel_row_html :: proc(db: Database, channel_index: int) -> string {
    channel_id := database.get_channel_id(db, channel_index)
    name := database.get_channel_name(db, channel_index)
    topic_count := database.get_num_topics_for_channel_index(db, channel_index);

    return fmt.tprintf(`
<div class="channel_row">
  <div class="channel_name">%s</div>
  <div><a href="/topics/%d">topics</a></div>
  <div class="channel_count">%d topics</div>
</div>
`,
        name,
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
