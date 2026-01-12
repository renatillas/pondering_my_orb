-record(player_state, {
    id :: shared@id:player_id(),
    position :: vec@vec3:vec3(float()),
    rotation :: float(),
    health :: float(),
    max_health :: float(),
    active_wand_index :: integer()
}).
