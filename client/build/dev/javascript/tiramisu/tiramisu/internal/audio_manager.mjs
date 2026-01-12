import * as $dict from "../../../gleam_stdlib/gleam/dict.mjs";
import * as $float from "../../../gleam_stdlib/gleam/float.mjs";
import * as $list from "../../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../../gleam_stdlib/gleam/order.mjs";
import * as $duration from "../../../gleam_time/gleam/time/duration.mjs";
import * as $savoiardi from "../../../savoiardi/savoiardi.mjs";
import { Ok, toList, prepend as listPrepend, CustomType as $CustomType } from "../../gleam.mjs";
import {
  playAudioWithFadeIn as play_audio_with_fade_in_ffi,
  playAudioWithFadeIn as play_positional_audio_with_fade_in_ffi,
  stopAudioWithFadeOut as stop_audio_with_fade_out_ffi,
  stopAudioWithFadeOut as stop_positional_audio_with_fade_out_ffi,
  getAudioContextStateFromListener as get_audio_context_state_from_listener,
  resumeAudioContextFromListener as resume_audio_context_from_listener,
} from "../../tiramisu.ffi.mjs";
import * as $audio from "../../tiramisu/audio.mjs";

export class GlobalSource extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Source$GlobalSource = ($0) => new GlobalSource($0);
export const Source$isGlobalSource = (value) => value instanceof GlobalSource;
export const Source$GlobalSource$0 = (value) => value[0];

export class PositionalSource extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Source$PositionalSource = ($0) => new PositionalSource($0);
export const Source$isPositionalSource = (value) =>
  value instanceof PositionalSource;
export const Source$PositionalSource$0 = (value) => value[0];

export class AudioSourceData extends $CustomType {
  constructor(three_source, base_volume, group, previous_state, on_end_callback) {
    super();
    this.three_source = three_source;
    this.base_volume = base_volume;
    this.group = group;
    this.previous_state = previous_state;
    this.on_end_callback = on_end_callback;
  }
}
export const AudioSourceData$AudioSourceData = (three_source, base_volume, group, previous_state, on_end_callback) =>
  new AudioSourceData(three_source,
  base_volume,
  group,
  previous_state,
  on_end_callback);
export const AudioSourceData$isAudioSourceData = (value) =>
  value instanceof AudioSourceData;
export const AudioSourceData$AudioSourceData$three_source = (value) =>
  value.three_source;
export const AudioSourceData$AudioSourceData$0 = (value) => value.three_source;
export const AudioSourceData$AudioSourceData$base_volume = (value) =>
  value.base_volume;
export const AudioSourceData$AudioSourceData$1 = (value) => value.base_volume;
export const AudioSourceData$AudioSourceData$group = (value) => value.group;
export const AudioSourceData$AudioSourceData$2 = (value) => value.group;
export const AudioSourceData$AudioSourceData$previous_state = (value) =>
  value.previous_state;
export const AudioSourceData$AudioSourceData$3 = (value) =>
  value.previous_state;
export const AudioSourceData$AudioSourceData$on_end_callback = (value) =>
  value.on_end_callback;
export const AudioSourceData$AudioSourceData$4 = (value) =>
  value.on_end_callback;

export class PendingPlayback extends $CustomType {
  constructor(id, source_data, fade_duration) {
    super();
    this.id = id;
    this.source_data = source_data;
    this.fade_duration = fade_duration;
  }
}
export const PendingPlayback$PendingPlayback = (id, source_data, fade_duration) =>
  new PendingPlayback(id, source_data, fade_duration);
export const PendingPlayback$isPendingPlayback = (value) =>
  value instanceof PendingPlayback;
export const PendingPlayback$PendingPlayback$id = (value) => value.id;
export const PendingPlayback$PendingPlayback$0 = (value) => value.id;
export const PendingPlayback$PendingPlayback$source_data = (value) =>
  value.source_data;
export const PendingPlayback$PendingPlayback$1 = (value) => value.source_data;
export const PendingPlayback$PendingPlayback$fade_duration = (value) =>
  value.fade_duration;
export const PendingPlayback$PendingPlayback$2 = (value) => value.fade_duration;

export class AudioManagerState extends $CustomType {
  constructor(sources, group_volumes, muted_groups, context_resumed, pending_playbacks) {
    super();
    this.sources = sources;
    this.group_volumes = group_volumes;
    this.muted_groups = muted_groups;
    this.context_resumed = context_resumed;
    this.pending_playbacks = pending_playbacks;
  }
}
export const AudioManagerState$AudioManagerState = (sources, group_volumes, muted_groups, context_resumed, pending_playbacks) =>
  new AudioManagerState(sources,
  group_volumes,
  muted_groups,
  context_resumed,
  pending_playbacks);
export const AudioManagerState$isAudioManagerState = (value) =>
  value instanceof AudioManagerState;
export const AudioManagerState$AudioManagerState$sources = (value) =>
  value.sources;
export const AudioManagerState$AudioManagerState$0 = (value) => value.sources;
export const AudioManagerState$AudioManagerState$group_volumes = (value) =>
  value.group_volumes;
export const AudioManagerState$AudioManagerState$1 = (value) =>
  value.group_volumes;
export const AudioManagerState$AudioManagerState$muted_groups = (value) =>
  value.muted_groups;
export const AudioManagerState$AudioManagerState$2 = (value) =>
  value.muted_groups;
export const AudioManagerState$AudioManagerState$context_resumed = (value) =>
  value.context_resumed;
export const AudioManagerState$AudioManagerState$3 = (value) =>
  value.context_resumed;
export const AudioManagerState$AudioManagerState$pending_playbacks = (value) =>
  value.pending_playbacks;
export const AudioManagerState$AudioManagerState$4 = (value) =>
  value.pending_playbacks;

/**
 * Create initial audio manager state
 */
export function init() {
  return new AudioManagerState(
    $dict.new$(),
    (() => {
      let _pipe = $dict.new$();
      let _pipe$1 = $dict.insert(_pipe, "sfx", 1.0);
      let _pipe$2 = $dict.insert(_pipe$1, "music", 1.0);
      let _pipe$3 = $dict.insert(_pipe$2, "voice", 1.0);
      return $dict.insert(_pipe$3, "ambient", 1.0);
    })(),
    toList([]),
    false,
    toList([]),
  );
}

/**
 * Register an audio source
 */
export function register_audio_source(state, id, source_data) {
  return new AudioManagerState(
    $dict.insert(state.sources, id, source_data),
    state.group_volumes,
    state.muted_groups,
    state.context_resumed,
    state.pending_playbacks,
  );
}

/**
 * Get audio source data by ID
 */
export function get_audio_source(state, id) {
  let _pipe = $dict.get(state.sources, id);
  return $option.from_result(_pipe);
}

/**
 * Get volume for an audio group
 */
export function get_group_volume(state, group_name) {
  let $ = $dict.get(state.group_volumes, group_name);
  if ($ instanceof Ok) {
    let volume = $[0];
    return volume;
  } else {
    return 1.0;
  }
}

/**
 * Calculate effective volume considering group volume and mute state
 * 
 * @ignore
 */
function calculate_effective_volume(state, base_volume, group) {
  if (group instanceof $option.Some) {
    let group_name = group[0];
    let group_volume = get_group_volume(state, group_name);
    let is_muted = $list.contains(state.muted_groups, group_name);
    if (is_muted) {
      return 0.0;
    } else {
      return base_volume * group_volume;
    }
  } else {
    return base_volume;
  }
}

/**
 * Clamp volume to 0.0-1.0 range
 * 
 * @ignore
 */
function clamp_volume(volume) {
  let $ = volume < 0.0;
  if ($) {
    return 0.0;
  } else {
    let $1 = volume > 1.0;
    if ($1) {
      return 1.0;
    } else {
      return volume;
    }
  }
}

/**
 * Convert AudioGroup to string
 * 
 * @ignore
 */
function audio_group_to_string(group) {
  if (group instanceof $audio.SFX) {
    return "sfx";
  } else if (group instanceof $audio.Music) {
    return "music";
  } else if (group instanceof $audio.Voice) {
    return "voice";
  } else if (group instanceof $audio.Ambient) {
    return "ambient";
  } else {
    let name = group[0];
    return name;
  }
}

/**
 * Check if source is playing
 * 
 * @ignore
 */
function is_source_playing(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.is_audio_playing(audio);
  } else {
    let audio = source[0];
    return $savoiardi.is_positional_audio_playing(audio);
  }
}

/**
 * Get loop state of source
 * 
 * @ignore
 */
function get_source_loop(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.get_audio_loop(audio);
  } else {
    let audio = source[0];
    return $savoiardi.get_positional_audio_loop(audio);
  }
}

/**
 * Stop audio source
 * 
 * @ignore
 */
function stop_source(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.stop_audio(audio);
  } else {
    let audio = source[0];
    return $savoiardi.stop_positional_audio(audio);
  }
}

/**
 * Unregister an audio source
 */
export function unregister_audio_source(state, id) {
  let $ = $dict.get(state.sources, id);
  if ($ instanceof Ok) {
    let source_data = $[0];
    let is_playing = is_source_playing(source_data.three_source);
    let is_looping = get_source_loop(source_data.three_source);
    let $1 = is_playing && is_looping;
    if ($1) {
      stop_source(source_data.three_source)
    } else {
      undefined
    }
  } else {
    undefined
  }
  return new AudioManagerState(
    $dict.delete$(state.sources, id),
    state.group_volumes,
    state.muted_groups,
    state.context_resumed,
    state.pending_playbacks,
  );
}

/**
 * Play audio source
 * 
 * @ignore
 */
function play_source(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.play_audio(audio);
  } else {
    let audio = source[0];
    return $savoiardi.play_positional_audio(audio);
  }
}

/**
 * Pause audio source
 * 
 * @ignore
 */
function pause_source(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.pause_audio(audio);
  } else {
    let audio = source[0];
    return $savoiardi.pause_positional_audio(audio);
  }
}

/**
 * Set source volume
 * 
 * @ignore
 */
function set_source_volume(source, volume) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.set_audio_volume(audio, volume);
  } else {
    let audio = source[0];
    return $savoiardi.set_positional_audio_volume(audio, volume);
  }
}

/**
 * Update all audio sources in a group
 * 
 * @ignore
 */
function update_sources_in_group(state, group_name) {
  let group_volume = get_group_volume(state, group_name);
  let is_muted = $list.contains(state.muted_groups, group_name);
  let updated_sources = $dict.map_values(
    state.sources,
    (_, source_data) => {
      let $ = source_data.group;
      if ($ instanceof $option.Some) {
        let g = $[0];
        if (g === group_name) {
          let _block;
          if (is_muted) {
            _block = 0.0;
          } else {
            _block = source_data.base_volume * group_volume;
          }
          let effective_volume = _block;
          set_source_volume(source_data.three_source, effective_volume);
          return source_data;
        } else {
          return source_data;
        }
      } else {
        return source_data;
      }
    },
  );
  return new AudioManagerState(
    updated_sources,
    state.group_volumes,
    state.muted_groups,
    state.context_resumed,
    state.pending_playbacks,
  );
}

/**
 * Set volume for an audio group
 */
export function set_group_volume(state, group_name, volume) {
  let clamped_volume = clamp_volume(volume);
  let state$1 = new AudioManagerState(
    state.sources,
    $dict.insert(state.group_volumes, group_name, clamped_volume),
    state.muted_groups,
    state.context_resumed,
    state.pending_playbacks,
  );
  return update_sources_in_group(state$1, group_name);
}

/**
 * Mute an audio group
 */
export function mute_group(state, group_name) {
  let state$1 = new AudioManagerState(
    state.sources,
    state.group_volumes,
    listPrepend(group_name, state.muted_groups),
    state.context_resumed,
    state.pending_playbacks,
  );
  return update_sources_in_group(state$1, group_name);
}

/**
 * Unmute an audio group
 */
export function unmute_group(state, group_name) {
  let state$1 = new AudioManagerState(
    state.sources,
    state.group_volumes,
    $list.filter(state.muted_groups, (g) => { return g !== group_name; }),
    state.context_resumed,
    state.pending_playbacks,
  );
  return update_sources_in_group(state$1, group_name);
}

/**
 * Set source loop
 * 
 * @ignore
 */
function set_source_loop(source, loop) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.set_audio_loop(audio, loop);
  } else {
    let audio = source[0];
    return $savoiardi.set_positional_audio_loop(audio, loop);
  }
}

/**
 * Set source playback rate
 * 
 * @ignore
 */
function set_source_playback_rate(source, rate) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.set_audio_playback_rate(audio, rate);
  } else {
    let audio = source[0];
    return $savoiardi.set_positional_audio_playback_rate(audio, rate);
  }
}

/**
 * Check if source has buffer
 * 
 * @ignore
 */
function has_source_buffer(source) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.has_audio_buffer(audio);
  } else {
    let audio = source[0];
    return $savoiardi.has_positional_audio_buffer(audio);
  }
}

/**
 * Set source buffer
 * 
 * @ignore
 */
function set_source_buffer(source, buffer) {
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return $savoiardi.set_audio_buffer(audio, buffer);
  } else {
    let audio = source[0];
    return $savoiardi.set_positional_audio_buffer(audio, buffer);
  }
}

/**
 * Play audio with fade in
 * 
 * @ignore
 */
function play_source_with_fade(source, fade_duration, target_volume) {
  let _block;
  let _pipe = fade_duration;
  let _pipe$1 = $duration.to_seconds(_pipe);
  let _pipe$2 = $float.multiply(_pipe$1, 1000.0);
  _block = $float.round(_pipe$2);
  let fade_ms = _block;
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return play_audio_with_fade_in_ffi(audio, fade_ms, target_volume);
  } else {
    let audio = source[0];
    return play_positional_audio_with_fade_in_ffi(audio, fade_ms, target_volume);
  }
}

/**
 * Play all pending audio sources
 * 
 * @ignore
 */
function play_pending_audio(state) {
  $list.each(
    state.pending_playbacks,
    (pending) => {
      let three_source = pending.source_data.three_source;
      let is_playing = is_source_playing(three_source);
      let has_buffer = has_source_buffer(three_source);
      let $ = !is_playing && has_buffer;
      if ($) {
        let $1 = $duration.compare(
          pending.fade_duration,
          $duration.milliseconds(0),
        ) instanceof $order.Gt;
        if ($1) {
          return play_source_with_fade(
            three_source,
            pending.fade_duration,
            pending.source_data.base_volume,
          );
        } else {
          return play_source(three_source);
        }
      } else {
        return undefined;
      }
    },
  );
  return new AudioManagerState(
    state.sources,
    state.group_volumes,
    state.muted_groups,
    state.context_resumed,
    toList([]),
  );
}

/**
 * Stop audio with fade out
 * 
 * @ignore
 */
function stop_source_with_fade(source, fade_duration, pause_instead_of_stop) {
  let _block;
  let _pipe = fade_duration;
  let _pipe$1 = $duration.to_seconds(_pipe);
  let _pipe$2 = $float.multiply(_pipe$1, 1000.0);
  _block = $float.round(_pipe$2);
  let fade_ms = _block;
  if (source instanceof GlobalSource) {
    let audio = source[0];
    return stop_audio_with_fade_out_ffi(audio, fade_ms, pause_instead_of_stop);
  } else {
    let audio = source[0];
    return stop_positional_audio_with_fade_out_ffi(
      audio,
      fade_ms,
      pause_instead_of_stop,
    );
  }
}

/**
 * Apply audio state (Playing, Paused, Stopped)
 */
export function apply_audio_state(
  state,
  id,
  source_data,
  buffer,
  config,
  audio_listener
) {
  let three_source = source_data.three_source;
  let _block;
  let $ = source_data.previous_state;
  if ($ instanceof $option.Some) {
    let s = $[0];
    _block = s;
  } else {
    _block = new $audio.Stopped();
  }
  let previous_state = _block;
  let current_state = config.state;
  let _block$1;
  let $1 = config.fade;
  if ($1 instanceof $audio.NoFade) {
    _block$1 = $duration.milliseconds(0);
  } else {
    let duration = $1.duration;
    _block$1 = duration;
  }
  let fade_duration = _block$1;
  let _block$2;
  if (current_state instanceof $audio.Playing) {
    if (previous_state instanceof $audio.Playing) {
      _block$2 = [state, source_data];
    } else {
      let has_buffer = has_source_buffer(three_source);
      if (has_buffer) {
        undefined
      } else {
        set_source_buffer(three_source, buffer)
      }
      let context_state = get_audio_context_state_from_listener(audio_listener);
      let $3 = context_state === "suspended";
      if ($3) {
        let pending = new PendingPlayback(id, source_data, fade_duration);
        let state$1 = new AudioManagerState(
          state.sources,
          state.group_volumes,
          state.muted_groups,
          state.context_resumed,
          listPrepend(pending, state.pending_playbacks),
        );
        _block$2 = [state$1, source_data];
      } else {
        let is_playing = is_source_playing(three_source);
        if (is_playing) {
          _block$2 = [state, source_data];
        } else {
          let _block$3;
          if (previous_state instanceof $audio.Paused) {
            _block$3 = true;
          } else {
            _block$3 = false;
          }
          let is_resuming_from_pause = _block$3;
          let $4 = ($duration.compare(fade_duration, $duration.milliseconds(0)) instanceof $order.Gt) && !is_resuming_from_pause;
          if ($4) {
            play_source_with_fade(
              three_source,
              fade_duration,
              source_data.base_volume,
            )
          } else {
            play_source(three_source);
            if (is_resuming_from_pause) {
              let effective_volume = calculate_effective_volume(
                state,
                source_data.base_volume,
                source_data.group,
              );
              set_source_volume(three_source, effective_volume)
            } else {
              undefined
            }
          }
          let updated_source_data = new AudioSourceData(
            source_data.three_source,
            source_data.base_volume,
            source_data.group,
            new $option.Some(new $audio.Playing()),
            source_data.on_end_callback,
          );
          _block$2 = [state, updated_source_data];
        }
      }
    }
  } else if (current_state instanceof $audio.Stopped) {
    if (previous_state instanceof $audio.Stopped) {
      _block$2 = [state, source_data];
    } else {
      let is_playing = is_source_playing(three_source);
      if (is_playing) {
        let $3 = $duration.compare(fade_duration, $duration.milliseconds(0)) instanceof $order.Gt;
        if ($3) {
          stop_source_with_fade(three_source, fade_duration, false)
        } else {
          stop_source(three_source)
        }
      } else {
        undefined
      }
      let updated_source_data = new AudioSourceData(
        source_data.three_source,
        source_data.base_volume,
        source_data.group,
        new $option.Some(new $audio.Stopped()),
        source_data.on_end_callback,
      );
      _block$2 = [state, updated_source_data];
    }
  } else {
    if (previous_state instanceof $audio.Paused) {
      _block$2 = [state, source_data];
    } else {
      let is_playing = is_source_playing(three_source);
      if (is_playing) {
        pause_source(three_source)
      } else {
        undefined
      }
      let updated_source_data = new AudioSourceData(
        source_data.three_source,
        source_data.base_volume,
        source_data.group,
        new $option.Some(new $audio.Paused()),
        source_data.on_end_callback,
      );
      _block$2 = [state, updated_source_data];
    }
  }
  let $2 = _block$2;
  let state$1;
  let source_data$1;
  state$1 = $2[0];
  source_data$1 = $2[1];
  return [state$1, source_data$1];
}

/**
 * Create and configure an audio source
 */
export function create_audio_source(
  state,
  id,
  buffer,
  config,
  audio_type,
  audio_listener
) {
  let _block;
  let $ = $dict.get(state.sources, id);
  if ($ instanceof Ok) {
    let existing = $[0];
    let is_playing = is_source_playing(existing.three_source);
    if (is_playing) {
      stop_source(existing.three_source)
    } else {
      undefined
    }
    _block = unregister_audio_source(state, id);
  } else {
    _block = state;
  }
  let state$1 = _block;
  let _block$1;
  if (audio_type instanceof $audio.GlobalAudio) {
    _block$1 = new GlobalSource($savoiardi.create_audio(audio_listener));
  } else {
    let ref_distance = audio_type.ref_distance;
    let rolloff_factor = audio_type.rolloff_factor;
    let max_distance = audio_type.max_distance;
    let pos_audio = $savoiardi.create_positional_audio(audio_listener);
    $savoiardi.set_ref_distance(pos_audio, ref_distance);
    $savoiardi.set_max_distance(pos_audio, max_distance);
    $savoiardi.set_rolloff_factor(pos_audio, rolloff_factor);
    _block$1 = new PositionalSource(pos_audio);
  }
  let three_source = _block$1;
  let _block$2;
  let $1 = config.group;
  if ($1 instanceof $option.Some) {
    let group = $1[0];
    _block$2 = new $option.Some(audio_group_to_string(group));
  } else {
    _block$2 = $1;
  }
  let group_name = _block$2;
  let effective_volume = calculate_effective_volume(
    state$1,
    config.volume,
    group_name,
  );
  set_source_volume(three_source, effective_volume);
  set_source_loop(three_source, config.loop);
  set_source_playback_rate(three_source, config.playback_rate);
  let source_data = new AudioSourceData(
    three_source,
    config.volume,
    group_name,
    new $option.None(),
    config.on_end,
  );
  let _block$3;
  let $3 = config.state;
  if ($3 instanceof $audio.Playing) {
    _block$3 = apply_audio_state(
      state$1,
      id,
      source_data,
      buffer,
      config,
      audio_listener,
    );
  } else if ($3 instanceof $audio.Stopped) {
    let source_data$1 = new AudioSourceData(
      source_data.three_source,
      source_data.base_volume,
      source_data.group,
      new $option.Some(config.state),
      source_data.on_end_callback,
    );
    _block$3 = [state$1, source_data$1];
  } else {
    let source_data$1 = new AudioSourceData(
      source_data.three_source,
      source_data.base_volume,
      source_data.group,
      new $option.Some(config.state),
      source_data.on_end_callback,
    );
    _block$3 = [state$1, source_data$1];
  }
  let $2 = _block$3;
  let state$2;
  let source_data$1;
  state$2 = $2[0];
  source_data$1 = $2[1];
  let state$3 = register_audio_source(state$2, id, source_data$1);
  return [state$3, source_data$1];
}

/**
 * Update audio configuration for existing source
 */
export function update_audio_config(state, id, buffer, config, audio_listener) {
  let $ = get_audio_source(state, id);
  if ($ instanceof $option.Some) {
    let source_data = $[0];
    let three_source = source_data.three_source;
    let updated_source_data = new AudioSourceData(
      source_data.three_source,
      config.volume,
      source_data.group,
      source_data.previous_state,
      config.on_end,
    );
    let effective_volume = calculate_effective_volume(
      state,
      config.volume,
      source_data.group,
    );
    set_source_volume(three_source, effective_volume);
    set_source_loop(three_source, config.loop);
    set_source_playback_rate(three_source, config.playback_rate);
    let $1 = apply_audio_state(
      state,
      id,
      updated_source_data,
      buffer,
      config,
      audio_listener,
    );
    let state$1;
    let updated_source_data$1;
    state$1 = $1[0];
    updated_source_data$1 = $1[1];
    return new AudioManagerState(
      $dict.insert(state$1.sources, id, updated_source_data$1),
      state$1.group_volumes,
      state$1.muted_groups,
      state$1.context_resumed,
      state$1.pending_playbacks,
    );
  } else {
    return state;
  }
}

/**
 * Resume AudioContext after user interaction
 * Takes the AudioListener from the renderer state to use the correct AudioContext
 */
export function resume_audio_context(state, audio_listener) {
  let $ = state.context_resumed;
  if ($) {
    return state;
  } else {
    let context_state = get_audio_context_state_from_listener(audio_listener);
    let $1 = context_state === "suspended";
    if ($1) {
      resume_audio_context_from_listener(audio_listener);
      let state$1 = new AudioManagerState(
        state.sources,
        state.group_volumes,
        state.muted_groups,
        true,
        state.pending_playbacks,
      );
      return play_pending_audio(state$1);
    } else {
      return new AudioManagerState(
        state.sources,
        state.group_volumes,
        state.muted_groups,
        true,
        state.pending_playbacks,
      );
    }
  }
}
