import filepath
import gleam.{Error as Err}
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/string
import simplifile.{type FileError, type FileInfo, Eacces, Enoent}

// Erlang - only dependencies
@target(erlang)
import gleam/erlang/process
@target(erlang)
import gleam/otp/actor
@target(erlang)
import gleam/otp/factory_supervisor
@target(erlang)
import gleam/otp/supervision

// -- TYPES --------------------------------------------------------------------

/// A filesystem event.
///
/// Polly is careful when handing you events, and makes sure that you always get
/// them in the right order, so if a dictionary with some files was created,
/// you will get the dictionary event first, before any children.
pub type Event {
  /// A new file or dictionary was created!
  Created(path: String)
  /// A file got modified!
  Changed(path: String)
  /// A file or dictionary got deleted :(
  Deleted(path: String)
  /// An unexpected simplifile error happened :(
  ///
  /// Polly treats `Enoent` and `Eacces` errors as if the file got deleted,
  /// and will therefore never pass those to you.
  Error(path: String, reason: FileError)
}

/// Polly uses the builder pattern to construct a watcher.
///
/// The `has_watched_dirs` phantom type variable helps Polly keep track of
/// wether or not you've called `add_dir` or `add_file` yet. That way, it will
/// be a type error if you try to watch nothing!
///
/// ```gleam
/// let options: Options = polly.new()
///     |> polly.add_dir("src")
///     |> polly.interval(3000)
///     |> polly.max_depth(10)
///     |> polly.filter(polly.default_filter)
/// ```
pub opaque type Options {
  Options(
    interval: Int,
    paths: List(String),
    max_depth: Int,
    filter: Filter,
    ignore_initial_missing: Bool,
    callbacks: List(Callback),
  )
}

type Filter =
  fn(simplifile.FileType, String) -> Bool

type Callback =
  fn(Event) -> Nil

/// A polling file system watcher, built from options.
///
/// Watchers are automatically started, and can by stopped by calling `stop`.
pub opaque type Watcher {
  Watcher(stop: fn() -> Nil)
}

// -- OPTIONS BUILDER ----------------------------------------------------------

/// Start creating a new configuration using the default options.
///
/// By default, an interval of 1 second is set, and the `default_filter` is used.
pub fn new() -> Options {
  Options(
    interval: 1000,
    paths: [],
    max_depth: -1,
    filter: default_filter,
    ignore_initial_missing: False,
    callbacks: [],
  )
}

/// Tell Polly which directory to watch. If it does not exist, `watch` will return an error.
///
/// If the directory goes away after watching has started, Polly will continue to
/// check on it to see if it came back.
///
/// Paths are not expanded by default, so the paths reported by events and passed
/// to the filter function will be prefixed with whatever you specified here.
pub fn add_dir(options: Options, path: String) -> Options {
  Options(..options, paths: [path, ..options.paths])
}

/// Tell Polly to watch a single file.
///
/// Polly doesn't care if you tell her to watch a file or directory, but
/// using this function makes your intent clearer!
pub fn add_file(options: Options, path: String) -> Options {
  add_dir(options, path)
}

/// Limit the maximum depth that Polly will walk each directory.
///
/// A limit of `0` would mean that Polly _only_ watches the specified list of
/// files or directories. A limit of `1` means that she will also look at the
/// files inside the given directories, but not at any nested directories.
///
/// There is no limit by default, but setting a limit might be good to
/// better control resource usage of the watcher.
///
/// Calling this function multiple times will cause polly to only remember the
/// lowest limit provided.
pub fn max_depth(options: Options, max_depth: Int) -> Options {
  case options.max_depth < 0 || max_depth < options.max_depth {
    True -> Options(..options, max_depth: max_depth)
    False -> options
  }
}

/// Set the interval in-between file-system polls, in milliseconds.
///
/// This is the time that Polly rests between calls, so if scanning your directory
/// tree takes 100ms, and you configured 1000ms here, the total time between calls
/// will roughly be 1100ms.
///
/// Doing it this way makes sure that Polly doesn't stumble over herself.
pub fn interval(options: Options, interval: Int) -> Options {
  case interval > 0 {
    True -> Options(..options, interval: interval)
    False -> options
  }
}

/// Filter files using the given predicate.
///
/// Polly will ignore files and directories for which the predicate returns `False`
/// completely, and any event happening for them or for a contained file of them
/// will not get reported.
///
/// Keep in mind that the filter is checked for every part of a path, not just
/// leaf nodes! So for example, if you have a path `./src/app.gleam`, your filter
/// function will first be called on `.`, then on `./src`, and then finally on
/// `./src/app.gleam`.
///
/// By default, all hidden files are ignored by using the `default_filter`.
pub fn filter(options: Options, by filter: Filter) -> Options {
  Options(..options, filter: filter)
}

/// The default filter function, ignoring hidden files starting with a colon `"."`
pub fn default_filter(_type: simplifile.FileType, path: String) -> Bool {
  case filepath.base_name(path) {
    "." | ".." -> True
    basename -> !string.starts_with(basename, ".")
  }
}

/// Tell Polly that it is fine if a file or directory does not exist initially.
///
/// By default, if a file or directory cannot be found when calling `watch`,
/// Polly will immediately return to you with an `Enoent` error and refuse to run.
///
/// When this option is active, Polly will instead note the missing directory,
/// and continuously check if it appears, similarly to how she does after a
/// file or directory goes away after she has first seen it.
pub fn ignore_initial_missing(options: Options) -> Options {
  Options(..options, ignore_initial_missing: True)
}

/// Add a callback function that Polly will call whenever she spots an event.
///
/// You can add multiple callbacks, and Polly will call them all in the order
/// you added them. The callbacks are called synchronously while she's collecting
/// change events, so it's a good idea to keep them light and fast!
pub fn add_callback(
  options: Options,
  on_event callback: fn(Event) -> Nil,
) -> Options {
  Options(..options, callbacks: [callback, ..options.callbacks])
}

@target(erlang)
/// Add a subject that Polly will send events to.
///
/// This is a convenience wrapper around `add_callback` for when you want to
/// send events to a process subject. Polly will use `process.send` to deliver
/// each event to your subject.
pub fn add_subject(
  options: Options,
  on_event subject: process.Subject(Event),
) -> Options {
  add_callback(options, on_event: process.send(subject, _))
}

// -- WATCH API ----------------------------------------------------------------

/// Tell Polly to start watching all the specified directories for changes.
///
/// The callbacks are called synchronously while collecting change events since
/// the last run. It is adviseable to move heavier cpu-bound tasks from this
/// callback into their own processes or threads.
///
/// When running on the Erlang target, this spawns a new linked process.
pub fn watch(options: Options) -> Result(Watcher, List(#(String, FileError))) {
  use roots <- result.try(get_initial_roots(options))

  let emit = broadcast(options.callbacks, _)
  let stop = repeatedly(options.interval, roots, step(options, emit, _))

  Ok(Watcher(stop:))
}

@target(erlang)
/// Create a child specification for running Polly under a supervisor.
///
/// This lets you add Polly to your supervision tree, so she'll automatically
/// restart if something goes wrong. The supervisor will make sure she keeps
/// watching your files reliably!
pub fn supervised(options: Options) -> supervision.ChildSpecification(Watcher) {
  use <- supervision.worker
  start_process(options)
}

@target(erlang)
/// Create a factory builder for dynamically starting multiple Polly watchers.
///
/// This is useful when you want to spawn and manage multiple watchers at runtime,
/// each watching different paths with different options. The factory supervisor
/// handles starting, stopping, and supervising all your Polly instances!
pub fn factory() -> factory_supervisor.Builder(Options, Watcher) {
  use options <- factory_supervisor.worker_child
  start_process(options)
}

@target(erlang)
fn start_process(
  options: Options,
) -> Result(actor.Started(Watcher), actor.StartError) {
  use roots <- result.try(
    get_initial_roots(options)
    |> result.map_error(fn(errors) { actor.InitFailed(describe_errors(errors)) }),
  )

  let emit = broadcast(options.callbacks, _)
  let #(pid, stop) = spawn(options.interval, roots, step(options, emit, _))

  Ok(actor.Started(pid, Watcher(stop)))
}

fn get_initial_roots(options: Options) {
  let Options(paths:, max_depth:, filter:, ignore_initial_missing:, ..) =
    options

  use <- bool.guard(when: paths == [], return: Err([]))

  use path <- list.try_map(paths)
  case init(filter, max_depth, path, "", []) {
    #(Some(vfs), []) -> Ok(#(path, Some(vfs)))
    // if the directory is not there on hydrate, this is an error by default.
    #(None, []) ->
      case ignore_initial_missing {
        False -> Err([#(path, Enoent)])
        True -> Ok(#(path, None))
      }
    #(_, errors) -> Err(errors)
  }
}

fn step(
  options: Options,
  emit: fn(Event) -> Nil,
  roots: List(#(String, Option(Vfs))),
) -> List(#(String, Option(Vfs))) {
  let Options(max_depth:, filter:, ..) = options

  use roots, #(path, vfs) <- list.fold(roots, [])

  case vfs {
    Some(vfs) -> {
      let new_vfs = diff(filter, max_depth, path, vfs, emit)

      [#(path, new_vfs), ..roots]
    }

    // check if the directory came back!
    option.None -> {
      let new_vfs = create(filter, max_depth, path, "", emit)

      [#(path, new_vfs), ..roots]
    }
  }
}

fn broadcast(callbacks: List(fn(Event) -> Nil), event: Event) {
  use callback <- list.each(callbacks)
  callback(event)
}

/// Stop this watcher.
///
/// If Polly currently scans your directories, she might not hear you right away
/// and may still report events for one run, after which she will stop.
pub fn stop(watcher: Watcher) -> Nil {
  watcher.stop()
}

/// Format a list of file errors into a human-readable string.
///
/// This is handy when `watch` returns errors and you want to show them to
/// your users. Each error is formatted as "path: description" on its own line.
pub fn describe_errors(errors: List(#(String, FileError))) -> String {
  errors
  |> list.map(fn(error) {
    let #(path, error) = error
    path <> ": " <> simplifile.describe_error(error)
  })
  |> string.join("\n")
}

// -- IMPLEMENTATION -----------------------------------------------------------

type Vfs {
  File(name: String, modkey: Int)
  Folder(name: String, modkey: Int, children: List(Vfs))
}

fn init(
  filter: Filter,
  depth: Int,
  path: String,
  name: String,
  errors: List(#(String, FileError)),
) -> #(Option(Vfs), List(#(String, FileError))) {
  let full_path = filepath.join(path, name)

  case simplifile.link_info(full_path) {
    Ok(stat) -> init_stat(filter, depth, name, full_path, stat, errors)
    Err(Enoent) | Err(Eacces) -> #(None, errors)
    Err(reason) -> #(None, [#(full_path, reason), ..errors])
  }
}

fn init_stat(
  filter: Filter,
  depth: Int,
  name: String,
  full_path: String,
  stat: FileInfo,
  errors: List(#(String, FileError)),
) -> #(Option(Vfs), List(#(String, FileError))) {
  let type_ = simplifile.file_info_type(stat)
  use <- bool.guard(when: !filter(type_, full_path), return: #(None, errors))

  case type_ {
    simplifile.File -> {
      #(Some(File(name, get_modkey(stat))), errors)
    }

    simplifile.Directory if depth == 0 -> {
      #(Some(Folder(name, get_modkey(stat), [])), errors)
    }

    simplifile.Directory if depth != 0 -> {
      case readdir(full_path) {
        Ok(entries) -> {
          let depth = depth - 1
          let #(children, errors) =
            init_children(filter, depth, full_path, entries, [], errors)
          #(Some(Folder(name, get_modkey(stat), children)), errors)
        }

        Err(Enoent) | Err(Eacces) -> #(None, errors)
        Err(reason) -> #(None, [#(full_path, reason), ..errors])
      }
    }

    _ -> #(None, [])
  }
}

fn init_children(
  filter: Filter,
  depth: Int,
  path: String,
  children: List(String),
  oks: List(Vfs),
  errors: List(#(String, FileError)),
) -> #(List(Vfs), List(#(String, FileError))) {
  case children {
    [] -> #(list.reverse(oks), errors)
    [first, ..rest] ->
      case init(filter, depth, path, first, errors) {
        #(Some(vfs), errors) ->
          init_children(filter, depth, path, rest, [vfs, ..oks], errors)

        #(None, errors) -> init_children(filter, depth, path, rest, oks, errors)
      }
  }
}

fn create(
  filter: Filter,
  depth: Int,
  path: String,
  name: String,
  emit: fn(Event) -> Nil,
) -> Option(Vfs) {
  let full_path = filepath.join(path, name)

  case simplifile.link_info(full_path) {
    Ok(stat) -> create_stat(filter, depth, name, full_path, stat, emit)
    Err(Enoent) | Err(Eacces) -> None
    Err(reason) -> {
      emit(Error(full_path, reason))
      None
    }
  }
}

fn create_stat(
  filter: Filter,
  depth: Int,
  name: String,
  full_path: String,
  stat: FileInfo,
  emit: fn(Event) -> Nil,
) -> Option(Vfs) {
  let type_ = simplifile.file_info_type(stat)
  use <- bool.guard(when: !filter(type_, full_path), return: None)

  case type_ {
    simplifile.File -> {
      emit(Created(full_path))
      Some(File(name, get_modkey(stat)))
    }

    simplifile.Directory if depth == 0 -> {
      emit(Created(full_path))
      Some(Folder(name, get_modkey(stat), []))
    }

    simplifile.Directory if depth != 0 -> {
      case readdir(full_path) {
        Ok(entries) -> {
          let depth = depth - 1
          emit(Created(full_path))
          let children =
            create_children(filter, depth, full_path, entries, [], emit)
          Some(Folder(name, get_modkey(stat), children))
        }

        Err(Enoent) | Err(Eacces) -> None
        Err(reason) -> {
          emit(Error(full_path, reason))
          None
        }
      }
    }

    _ -> None
  }
}

fn create_children(
  filter: Filter,
  depth: Int,
  path: String,
  children: List(String),
  oks: List(Vfs),
  emit: fn(Event) -> Nil,
) -> List(Vfs) {
  case children {
    [] -> list.reverse(oks)
    [first, ..rest] ->
      case create(filter, depth, path, first, emit) {
        Some(vfs) ->
          create_children(filter, depth, path, rest, [vfs, ..oks], emit)

        None -> create_children(filter, depth, path, rest, oks, emit)
      }
  }
}

fn diff(
  filter: Filter,
  depth: Int,
  path: String,
  vfs: Vfs,
  emit: fn(Event) -> Nil,
) -> Option(Vfs) {
  let full_path = filepath.join(path, vfs.name)
  case simplifile.link_info(full_path) {
    Ok(stat) -> {
      let type_ = simplifile.file_info_type(stat)
      case filter(type_, full_path) {
        True ->
          case type_, vfs {
            simplifile.File, File(name:, modkey: old_key) -> {
              let new_key = get_modkey(stat)
              case new_key == old_key {
                // hurray for reuse
                True -> Some(vfs)
                False -> {
                  emit(Changed(full_path))
                  Some(File(name, new_key))
                }
              }
            }

            simplifile.Directory, Folder(..) if depth == 0 -> {
              // NOTE: we do not send change events for directories, so there is nothing to do.
              Some(vfs)
            }

            simplifile.Directory, Folder(name:, children: old_children, ..)
              if depth != 0
            ->
              case readdir(full_path) {
                Ok(new_entries) -> {
                  let children =
                    diff_children(
                      filter,
                      depth - 1,
                      full_path,
                      old_children,
                      new_entries,
                      [],
                      emit,
                    )

                  Some(Folder(name, get_modkey(stat), children))
                }

                Err(Enoent) | Err(Eacces) -> {
                  delete(path, vfs, emit)
                  None
                }

                Err(reason) -> {
                  emit(Error(full_path, reason))
                  Some(vfs)
                }
              }

            _, _ -> {
              delete(path, vfs, emit)
              create_stat(filter, depth, vfs.name, full_path, stat, emit)
            }
          }

        // we had a VFS, but now we should skip it -> emit deletes
        False -> {
          delete(path, vfs, emit)
          None
        }
      }
    }

    // enoent might happen if the file is deleted while we are scanning
    Err(Eacces) | Err(Enoent) -> {
      delete(path, vfs, emit)
      None
    }

    Err(reason) -> {
      emit(Error(path, reason))
      Some(vfs)
    }
  }
}

fn diff_children(
  filter: Filter,
  depth: Int,
  path: String,
  old_children: List(Vfs),
  new_entries: List(String),
  new_children: List(Vfs),
  emit: fn(Event) -> Nil,
) -> List(Vfs) {
  case old_children, new_entries {
    [], [] -> list.reverse(new_children)
    [first_old, ..rest_old], [first_new, ..rest_new] ->
      case string.compare(first_old.name, first_new) {
        order.Eq -> {
          case diff(filter, depth, path, first_old, emit) {
            Some(new_vfs) ->
              diff_children(
                filter,
                depth,
                path,
                rest_old,
                rest_new,
                [new_vfs, ..new_children],
                emit,
              )

            None ->
              diff_children(
                filter,
                depth,
                path,
                rest_old,
                rest_new,
                new_children,
                emit,
              )
          }
        }

        order.Gt -> {
          // created a file
          let new_children = case create(filter, depth, path, first_new, emit) {
            Some(new_vfs) -> [new_vfs, ..new_children]
            None -> new_children
          }

          diff_children(
            filter,
            depth,
            path,
            old_children,
            rest_new,
            new_children,
            emit,
          )
        }

        order.Lt -> {
          // deleted a file
          delete(path, first_old, emit)
          diff_children(
            filter,
            depth,
            path,
            rest_old,
            new_entries,
            new_children,
            emit,
          )
        }
      }

    [], [first_new, ..rest_new] -> {
      let new_children = case create(filter, depth, path, first_new, emit) {
        Some(new_vfs) -> [new_vfs, ..new_children]
        None -> new_children
      }

      diff_children(
        filter,
        depth,
        path,
        old_children,
        rest_new,
        new_children,
        emit,
      )
    }

    [first_old, ..rest_old], [] -> {
      // deleted all the remaining old ones
      delete(path, first_old, emit)
      diff_children(
        filter,
        depth,
        path,
        rest_old,
        new_entries,
        new_children,
        emit,
      )
    }
  }
}

fn delete(path: String, vfs: Vfs, emit: fn(Event) -> Nil) -> Nil {
  let full_path = filepath.join(path, vfs.name)
  case vfs {
    File(..) -> emit(Deleted(full_path))
    Folder(children:, ..) -> {
      list.each(children, fn(child) { delete(full_path, child, emit) })
      emit(Deleted(full_path))
    }
  }
}

fn get_modkey(stat: simplifile.FileInfo) -> Int {
  int.max(stat.mtime_seconds, stat.ctime_seconds)
}

fn readdir(path: String) -> Result(List(String), FileError) {
  simplifile.read_directory(path)
  |> result.map(list.sort(_, by: string.compare))
}

// -- EXTERNAL -----------------------------------------------------------------

@external(erlang, "polly_ffi", "repeatedly")
@external(javascript, "./polly_ffi.mjs", "repeatedly")
fn repeatedly(
  timeout: Int,
  initial state: state,
  with callback: fn(state) -> state,
) -> fn() -> Nil

@target(erlang)
@external(erlang, "polly_ffi", "spawn")
fn spawn(
  timeout: Int,
  initial state: state,
  with callback: fn(state) -> state,
) -> #(process.Pid, fn() -> Nil)
