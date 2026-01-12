-record(room_joined, {
    room_id :: shared@id:room_id(),
    player_id :: shared@id:player_id(),
    players :: list(shared@player_state:player_state())
}).
