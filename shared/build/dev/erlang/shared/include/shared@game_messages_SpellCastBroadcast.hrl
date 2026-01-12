-record(spell_cast_broadcast, {
    caster_id :: shared@id:player_id(),
    wand_index :: integer(),
    direction :: vec@vec3:vec3(float())
}).
