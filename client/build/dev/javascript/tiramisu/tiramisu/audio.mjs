import * as $promise from "../../gleam_javascript/gleam/javascript/promise.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $savoiardi from "../../savoiardi/savoiardi.mjs";
import { Ok, CustomType as $CustomType } from "../gleam.mjs";
import * as $effect from "../tiramisu/effect.mjs";

export class SFX extends $CustomType {}
export const Group$SFX = () => new SFX();
export const Group$isSFX = (value) => value instanceof SFX;

export class Music extends $CustomType {}
export const Group$Music = () => new Music();
export const Group$isMusic = (value) => value instanceof Music;

export class Voice extends $CustomType {}
export const Group$Voice = () => new Voice();
export const Group$isVoice = (value) => value instanceof Voice;

export class Ambient extends $CustomType {}
export const Group$Ambient = () => new Ambient();
export const Group$isAmbient = (value) => value instanceof Ambient;

/**
 * Custom group with a name
 */
export class Custom extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Group$Custom = ($0) => new Custom($0);
export const Group$isCustom = (value) => value instanceof Custom;
export const Group$Custom$0 = (value) => value[0];

export class Playing extends $CustomType {}
export const AudioState$Playing = () => new Playing();
export const AudioState$isPlaying = (value) => value instanceof Playing;

export class Stopped extends $CustomType {}
export const AudioState$Stopped = () => new Stopped();
export const AudioState$isStopped = (value) => value instanceof Stopped;

export class Paused extends $CustomType {}
export const AudioState$Paused = () => new Paused();
export const AudioState$isPaused = (value) => value instanceof Paused;

export class NoFade extends $CustomType {}
export const FadeConfig$NoFade = () => new NoFade();
export const FadeConfig$isNoFade = (value) => value instanceof NoFade;

/**
 * Fade in/out over specified milliseconds
 */
export class Fade extends $CustomType {
  constructor(duration) {
    super();
    this.duration = duration;
  }
}
export const FadeConfig$Fade = (duration) => new Fade(duration);
export const FadeConfig$isFade = (value) => value instanceof Fade;
export const FadeConfig$Fade$duration = (value) => value.duration;
export const FadeConfig$Fade$0 = (value) => value.duration;

export class AudioConfig extends $CustomType {
  constructor(state, volume, loop, playback_rate, fade, group, on_end) {
    super();
    this.state = state;
    this.volume = volume;
    this.loop = loop;
    this.playback_rate = playback_rate;
    this.fade = fade;
    this.group = group;
    this.on_end = on_end;
  }
}
export const Config$AudioConfig = (state, volume, loop, playback_rate, fade, group, on_end) =>
  new AudioConfig(state, volume, loop, playback_rate, fade, group, on_end);
export const Config$isAudioConfig = (value) => value instanceof AudioConfig;
export const Config$AudioConfig$state = (value) => value.state;
export const Config$AudioConfig$0 = (value) => value.state;
export const Config$AudioConfig$volume = (value) => value.volume;
export const Config$AudioConfig$1 = (value) => value.volume;
export const Config$AudioConfig$loop = (value) => value.loop;
export const Config$AudioConfig$2 = (value) => value.loop;
export const Config$AudioConfig$playback_rate = (value) => value.playback_rate;
export const Config$AudioConfig$3 = (value) => value.playback_rate;
export const Config$AudioConfig$fade = (value) => value.fade;
export const Config$AudioConfig$4 = (value) => value.fade;
export const Config$AudioConfig$group = (value) => value.group;
export const Config$AudioConfig$5 = (value) => value.group;
export const Config$AudioConfig$on_end = (value) => value.on_end;
export const Config$AudioConfig$6 = (value) => value.on_end;

/**
 * Global audio (2D, same volume everywhere)
 */
export class GlobalAudio extends $CustomType {
  constructor(buffer, config) {
    super();
    this.buffer = buffer;
    this.config = config;
  }
}
export const Audio$GlobalAudio = (buffer, config) =>
  new GlobalAudio(buffer, config);
export const Audio$isGlobalAudio = (value) => value instanceof GlobalAudio;
export const Audio$GlobalAudio$buffer = (value) => value.buffer;
export const Audio$GlobalAudio$0 = (value) => value.buffer;
export const Audio$GlobalAudio$config = (value) => value.config;
export const Audio$GlobalAudio$1 = (value) => value.config;

/**
 * Positional audio (3D, volume based on distance)
 */
export class PositionalAudio extends $CustomType {
  constructor(buffer, config, ref_distance, rolloff_factor, max_distance) {
    super();
    this.buffer = buffer;
    this.config = config;
    this.ref_distance = ref_distance;
    this.rolloff_factor = rolloff_factor;
    this.max_distance = max_distance;
  }
}
export const Audio$PositionalAudio = (buffer, config, ref_distance, rolloff_factor, max_distance) =>
  new PositionalAudio(buffer, config, ref_distance, rolloff_factor, max_distance);
export const Audio$isPositionalAudio = (value) =>
  value instanceof PositionalAudio;
export const Audio$PositionalAudio$buffer = (value) => value.buffer;
export const Audio$PositionalAudio$0 = (value) => value.buffer;
export const Audio$PositionalAudio$config = (value) => value.config;
export const Audio$PositionalAudio$1 = (value) => value.config;
export const Audio$PositionalAudio$ref_distance = (value) => value.ref_distance;
export const Audio$PositionalAudio$2 = (value) => value.ref_distance;
export const Audio$PositionalAudio$rolloff_factor = (value) =>
  value.rolloff_factor;
export const Audio$PositionalAudio$3 = (value) => value.rolloff_factor;
export const Audio$PositionalAudio$max_distance = (value) => value.max_distance;
export const Audio$PositionalAudio$4 = (value) => value.max_distance;

export const Audio$buffer = (value) => value.buffer;
export const Audio$config = (value) => value.config;

/**
 * Create default audio config (stopped, no fade)
 */
export function config() {
  return new AudioConfig(
    new Stopped(),
    1.0,
    false,
    1.0,
    new NoFade(),
    new $option.None(),
    new $option.None(),
  );
}

/**
 * Create audio config that starts playing
 */
export function playing() {
  return new AudioConfig(
    new Playing(),
    1.0,
    false,
    1.0,
    new NoFade(),
    new $option.None(),
    new $option.None(),
  );
}

/**
 * Set playback state (Playing, Stopped, Paused)
 */
export function with_state(config, state) {
  return new AudioConfig(
    state,
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set audio to playing
 */
export function with_playing(config) {
  return new AudioConfig(
    new Playing(),
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set audio to stopped
 */
export function with_stopped(config) {
  return new AudioConfig(
    new Stopped(),
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set audio to paused
 */
export function with_paused(config) {
  return new AudioConfig(
    new Paused(),
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set fade configuration
 */
export function with_fade(config, duration) {
  return new AudioConfig(
    config.state,
    config.volume,
    config.loop,
    config.playback_rate,
    new Fade(duration),
    config.group,
    config.on_end,
  );
}

/**
 * Set no fade (instant transitions)
 */
export function with_no_fade(config) {
  return new AudioConfig(
    config.state,
    config.volume,
    config.loop,
    config.playback_rate,
    new NoFade(),
    config.group,
    config.on_end,
  );
}

/**
 * Set volume in config (0.0 to 1.0)
 */
export function with_volume(config, volume) {
  return new AudioConfig(
    config.state,
    volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set looping in config
 */
export function with_loop(config, loop) {
  return new AudioConfig(
    config.state,
    config.volume,
    loop,
    config.playback_rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set playback rate in config (1.0 = normal, 2.0 = double speed, etc.)
 */
export function with_playback_rate(config, rate) {
  return new AudioConfig(
    config.state,
    config.volume,
    config.loop,
    rate,
    config.fade,
    config.group,
    config.on_end,
  );
}

/**
 * Set audio group in config
 */
export function with_group(config, group) {
  return new AudioConfig(
    config.state,
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    new $option.Some(group),
    config.on_end,
  );
}

/**
 * Set callback to be called when audio ends (for non-looping audio)
 *
 * This is useful for one-shot sounds like SFX where you need to know
 * when the sound has finished playing.
 *
 * ## Example
 *
 * ```gleam
 * audio.config()
 * |> audio.with_state(audio.Playing)
 * |> audio.with_on_end(fn() {
 *   // Audio finished playing
 *   io.println("SFX finished!")
 * })
 * ```
 */
export function with_on_end(config, callback) {
  return new AudioConfig(
    config.state,
    config.volume,
    config.loop,
    config.playback_rate,
    config.fade,
    config.group,
    new $option.Some(callback),
  );
}

/**
 * Create global audio (2D, same volume everywhere)
 */
export function global(buffer, config) {
  return new GlobalAudio(buffer, config);
}

/**
 * Create a default positional audio configuration
 */
export function positional(buffer, config) {
  return new PositionalAudio(buffer, config, 1.0, 1.0, 10000.0);
}

/**
 * Set reference distance for positional audio
 */
export function with_ref_distance(audio, distance) {
  if (audio instanceof GlobalAudio) {
    return audio;
  } else {
    let buffer = audio.buffer;
    let config$1 = audio.config;
    let rolloff = audio.rolloff_factor;
    let max = audio.max_distance;
    return new PositionalAudio(buffer, config$1, distance, rolloff, max);
  }
}

/**
 * Set rolloff factor for positional audio
 */
export function with_rolloff_factor(audio, factor) {
  if (audio instanceof GlobalAudio) {
    return audio;
  } else {
    let buffer = audio.buffer;
    let config$1 = audio.config;
    let ref = audio.ref_distance;
    let max = audio.max_distance;
    return new PositionalAudio(buffer, config$1, ref, factor, max);
  }
}

/**
 * Set maximum distance for positional audio
 */
export function with_max_distance(audio, distance) {
  if (audio instanceof GlobalAudio) {
    return audio;
  } else {
    let buffer = audio.buffer;
    let config$1 = audio.config;
    let ref = audio.ref_distance;
    let rolloff = audio.rolloff_factor;
    return new PositionalAudio(buffer, config$1, ref, rolloff, distance);
  }
}

/**
 * Load an audio file from URL
 */
export function load_audio(url, on_success, on_error) {
  let _block;
  let _pipe = $savoiardi.load_audio(url);
  _block = $promise.map(
    _pipe,
    (result) => {
      if (result instanceof Ok) {
        let data = result[0];
        return on_success(data);
      } else {
        return on_error;
      }
    },
  );
  let promise = _block;
  return $effect.from_promise(promise);
}
