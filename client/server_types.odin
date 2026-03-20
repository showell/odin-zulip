package client

ServerSubscription :: struct {
    stream_id: int,
    name: string,
}

ServerMessage :: struct {
    content: string,
    id: int,
    sender_full_name: string,
    sender_id: int,
    subject: string,
    stream_id: int,
}
