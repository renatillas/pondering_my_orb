import * as $filepath from "../filepath/filepath.mjs";
import * as $bool from "../gleam_stdlib/gleam/bool.mjs";
import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $option from "../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../gleam_stdlib/gleam/option.mjs";
import * as $order from "../gleam_stdlib/gleam/order.mjs";
import * as $result from "../gleam_stdlib/gleam/result.mjs";
import * as $string from "../gleam_stdlib/gleam/string.mjs";
import * as $simplifile from "../simplifile/simplifile.mjs";
import { Eacces, Enoent } from "../simplifile/simplifile.mjs";
import * as $gleam from "./gleam.mjs";
import {
  Error as Err,
  Ok,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  isEqual,
} from "./gleam.mjs";
import { repeatedly } from "./polly_ffi.mjs";

/**
 * A new file or dictionary was created!
 */
export class Created extends $CustomType {
  constructor(path) {
    super();
    this.path = path;
  }
}
export const Event$Created = (path) => new Created(path);
export const Event$isCreated = (value) => value instanceof Created;
export const Event$Created$path = (value) => value.path;
export const Event$Created$0 = (value) => value.path;

/**
 * A file got modified!
 */
export class Changed extends $CustomType {
  constructor(path) {
    super();
    this.path = path;
  }
}
export const Event$Changed = (path) => new Changed(path);
export const Event$isChanged = (value) => value instanceof Changed;
export const Event$Changed$path = (value) => value.path;
export const Event$Changed$0 = (value) => value.path;

/**
 * A file or dictionary got deleted :(
 */
export class Deleted extends $CustomType {
  constructor(path) {
    super();
    this.path = path;
  }
}
export const Event$Deleted = (path) => new Deleted(path);
export const Event$isDeleted = (value) => value instanceof Deleted;
export const Event$Deleted$path = (value) => value.path;
export const Event$Deleted$0 = (value) => value.path;

/**
 * An unexpected simplifile error happened :(
 *
 * Polly treats `Enoent` and `Eacces` errors as if the file got deleted,
 * and will therefore never pass those to you.
 */
export class Error extends $CustomType {
  constructor(path, reason) {
    super();
    this.path = path;
    this.reason = reason;
  }
}
export const Event$Error = (path, reason) => new Error(path, reason);
export const Event$isError = (value) => value instanceof Error;
export const Event$Error$path = (value) => value.path;
export const Event$Error$0 = (value) => value.path;
export const Event$Error$reason = (value) => value.reason;
export const Event$Error$1 = (value) => value.reason;

export const Event$path = (value) => value.path;

class Options extends $CustomType {
  constructor(interval, paths, max_depth, filter, ignore_initial_missing, callbacks) {
    super();
    this.interval = interval;
    this.paths = paths;
    this.max_depth = max_depth;
    this.filter = filter;
    this.ignore_initial_missing = ignore_initial_missing;
    this.callbacks = callbacks;
  }
}

class Watcher extends $CustomType {
  constructor(stop) {
    super();
    this.stop = stop;
  }
}

class File extends $CustomType {
  constructor(name, modkey) {
    super();
    this.name = name;
    this.modkey = modkey;
  }
}

class Folder extends $CustomType {
  constructor(name, modkey, children) {
    super();
    this.name = name;
    this.modkey = modkey;
    this.children = children;
  }
}

/**
 * Tell Polly which directory to watch. If it does not exist, `watch` will return an error.
 *
 * If the directory goes away after watching has started, Polly will continue to
 * check on it to see if it came back.
 *
 * Paths are not expanded by default, so the paths reported by events and passed
 * to the filter function will be prefixed with whatever you specified here.
 */
export function add_dir(options, path) {
  return new Options(
    options.interval,
    listPrepend(path, options.paths),
    options.max_depth,
    options.filter,
    options.ignore_initial_missing,
    options.callbacks,
  );
}

/**
 * Tell Polly to watch a single file.
 *
 * Polly doesn't care if you tell her to watch a file or directory, but
 * using this function makes your intent clearer!
 */
export function add_file(options, path) {
  return add_dir(options, path);
}

/**
 * Limit the maximum depth that Polly will walk each directory.
 *
 * A limit of `0` would mean that Polly _only_ watches the specified list of
 * files or directories. A limit of `1` means that she will also look at the
 * files inside the given directories, but not at any nested directories.
 *
 * There is no limit by default, but setting a limit might be good to
 * better control resource usage of the watcher.
 *
 * Calling this function multiple times will cause polly to only remember the
 * lowest limit provided.
 */
export function max_depth(options, max_depth) {
  let $ = (options.max_depth < 0) || (max_depth < options.max_depth);
  if ($) {
    return new Options(
      options.interval,
      options.paths,
      max_depth,
      options.filter,
      options.ignore_initial_missing,
      options.callbacks,
    );
  } else {
    return options;
  }
}

/**
 * Set the interval in-between file-system polls, in milliseconds.
 *
 * This is the time that Polly rests between calls, so if scanning your directory
 * tree takes 100ms, and you configured 1000ms here, the total time between calls
 * will roughly be 1100ms.
 *
 * Doing it this way makes sure that Polly doesn't stumble over herself.
 */
export function interval(options, interval) {
  let $ = interval > 0;
  if ($) {
    return new Options(
      interval,
      options.paths,
      options.max_depth,
      options.filter,
      options.ignore_initial_missing,
      options.callbacks,
    );
  } else {
    return options;
  }
}

/**
 * Filter files using the given predicate.
 *
 * Polly will ignore files and directories for which the predicate returns `False`
 * completely, and any event happening for them or for a contained file of them
 * will not get reported.
 *
 * Keep in mind that the filter is checked for every part of a path, not just
 * leaf nodes! So for example, if you have a path `./src/app.gleam`, your filter
 * function will first be called on `.`, then on `./src`, and then finally on
 * `./src/app.gleam`.
 *
 * By default, all hidden files are ignored by using the `default_filter`.
 */
export function filter(options, filter) {
  return new Options(
    options.interval,
    options.paths,
    options.max_depth,
    filter,
    options.ignore_initial_missing,
    options.callbacks,
  );
}

/**
 * The default filter function, ignoring hidden files starting with a colon `"."`
 */
export function default_filter(_, path) {
  let $ = $filepath.base_name(path);
  if ($ === ".") {
    return true;
  } else if ($ === "..") {
    return true;
  } else {
    let basename = $;
    return !$string.starts_with(basename, ".");
  }
}

/**
 * Start creating a new configuration using the default options.
 *
 * By default, an interval of 1 second is set, and the `default_filter` is used.
 */
export function new$() {
  return new Options(1000, toList([]), -1, default_filter, false, toList([]));
}

/**
 * Tell Polly that it is fine if a file or directory does not exist initially.
 *
 * By default, if a file or directory cannot be found when calling `watch`,
 * Polly will immediately return to you with an `Enoent` error and refuse to run.
 *
 * When this option is active, Polly will instead note the missing directory,
 * and continuously check if it appears, similarly to how she does after a
 * file or directory goes away after she has first seen it.
 */
export function ignore_initial_missing(options) {
  return new Options(
    options.interval,
    options.paths,
    options.max_depth,
    options.filter,
    true,
    options.callbacks,
  );
}

/**
 * Add a callback function that Polly will call whenever she spots an event.
 *
 * You can add multiple callbacks, and Polly will call them all in the order
 * you added them. The callbacks are called synchronously while she's collecting
 * change events, so it's a good idea to keep them light and fast!
 */
export function add_callback(options, callback) {
  return new Options(
    options.interval,
    options.paths,
    options.max_depth,
    options.filter,
    options.ignore_initial_missing,
    listPrepend(callback, options.callbacks),
  );
}

function broadcast(callbacks, event) {
  return $list.each(callbacks, (callback) => { return callback(event); });
}

/**
 * Stop this watcher.
 *
 * If Polly currently scans your directories, she might not hear you right away
 * and may still report events for one run, after which she will stop.
 */
export function stop(watcher) {
  return watcher.stop();
}

/**
 * Format a list of file errors into a human-readable string.
 *
 * This is handy when `watch` returns errors and you want to show them to
 * your users. Each error is formatted as "path: description" on its own line.
 */
export function describe_errors(errors) {
  let _pipe = errors;
  let _pipe$1 = $list.map(
    _pipe,
    (error) => {
      let path;
      let error$1;
      path = error[0];
      error$1 = error[1];
      return (path + ": ") + $simplifile.describe_error(error$1);
    },
  );
  return $string.join(_pipe$1, "\n");
}

function delete$(path, vfs, emit) {
  let full_path = $filepath.join(path, vfs.name);
  if (vfs instanceof File) {
    return emit(new Deleted(full_path));
  } else {
    let children = vfs.children;
    $list.each(children, (child) => { return delete$(full_path, child, emit); });
    return emit(new Deleted(full_path));
  }
}

function get_modkey(stat) {
  return $int.max(stat.mtime_seconds, stat.ctime_seconds);
}

function readdir(path) {
  let _pipe = $simplifile.read_directory(path);
  return $result.map(
    _pipe,
    (_capture) => { return $list.sort(_capture, $string.compare); },
  );
}

function diff_children(
  loop$filter,
  loop$depth,
  loop$path,
  loop$old_children,
  loop$new_entries,
  loop$new_children,
  loop$emit
) {
  while (true) {
    let filter = loop$filter;
    let depth = loop$depth;
    let path = loop$path;
    let old_children = loop$old_children;
    let new_entries = loop$new_entries;
    let new_children = loop$new_children;
    let emit = loop$emit;
    if (old_children instanceof $Empty) {
      if (new_entries instanceof $Empty) {
        return $list.reverse(new_children);
      } else {
        let first_new = new_entries.head;
        let rest_new = new_entries.tail;
        let _block;
        let $ = create(filter, depth, path, first_new, emit);
        if ($ instanceof Some) {
          let new_vfs = $[0];
          _block = listPrepend(new_vfs, new_children);
        } else {
          _block = new_children;
        }
        let new_children$1 = _block;
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$old_children = old_children;
        loop$new_entries = rest_new;
        loop$new_children = new_children$1;
        loop$emit = emit;
      }
    } else if (new_entries instanceof $Empty) {
      let first_old = old_children.head;
      let rest_old = old_children.tail;
      delete$(path, first_old, emit);
      loop$filter = filter;
      loop$depth = depth;
      loop$path = path;
      loop$old_children = rest_old;
      loop$new_entries = new_entries;
      loop$new_children = new_children;
      loop$emit = emit;
    } else {
      let first_old = old_children.head;
      let rest_old = old_children.tail;
      let first_new = new_entries.head;
      let rest_new = new_entries.tail;
      let $ = $string.compare(first_old.name, first_new);
      if ($ instanceof $order.Lt) {
        delete$(path, first_old, emit);
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$old_children = rest_old;
        loop$new_entries = new_entries;
        loop$new_children = new_children;
        loop$emit = emit;
      } else if ($ instanceof $order.Eq) {
        let $1 = diff(filter, depth, path, first_old, emit);
        if ($1 instanceof Some) {
          let new_vfs = $1[0];
          loop$filter = filter;
          loop$depth = depth;
          loop$path = path;
          loop$old_children = rest_old;
          loop$new_entries = rest_new;
          loop$new_children = listPrepend(new_vfs, new_children);
          loop$emit = emit;
        } else {
          loop$filter = filter;
          loop$depth = depth;
          loop$path = path;
          loop$old_children = rest_old;
          loop$new_entries = rest_new;
          loop$new_children = new_children;
          loop$emit = emit;
        }
      } else {
        let _block;
        let $1 = create(filter, depth, path, first_new, emit);
        if ($1 instanceof Some) {
          let new_vfs = $1[0];
          _block = listPrepend(new_vfs, new_children);
        } else {
          _block = new_children;
        }
        let new_children$1 = _block;
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$old_children = old_children;
        loop$new_entries = rest_new;
        loop$new_children = new_children$1;
        loop$emit = emit;
      }
    }
  }
}

function diff(filter, depth, path, vfs, emit) {
  let full_path = $filepath.join(path, vfs.name);
  let $ = $simplifile.link_info(full_path);
  if ($ instanceof Ok) {
    let stat = $[0];
    let type_ = $simplifile.file_info_type(stat);
    let $1 = filter(type_, full_path);
    if ($1) {
      if (vfs instanceof File) {
        if (type_ instanceof $simplifile.File) {
          let name = vfs.name;
          let old_key = vfs.modkey;
          let new_key = get_modkey(stat);
          let $2 = new_key === old_key;
          if ($2) {
            return new Some(vfs);
          } else {
            emit(new Changed(full_path));
            return new Some(new File(name, new_key));
          }
        } else {
          delete$(path, vfs, emit);
          return create_stat(filter, depth, vfs.name, full_path, stat, emit);
        }
      } else if (type_ instanceof $simplifile.Directory) {
        if (depth === 0) {
          return new Some(vfs);
        } else if (depth !== 0) {
          let name = vfs.name;
          let old_children = vfs.children;
          let $2 = readdir(full_path);
          if ($2 instanceof Ok) {
            let new_entries = $2[0];
            let children = diff_children(
              filter,
              depth - 1,
              full_path,
              old_children,
              new_entries,
              toList([]),
              emit,
            );
            return new Some(new Folder(name, get_modkey(stat), children));
          } else {
            let $3 = $2[0];
            if ($3 instanceof Eacces) {
              delete$(path, vfs, emit);
              return new None();
            } else if ($3 instanceof Enoent) {
              delete$(path, vfs, emit);
              return new None();
            } else {
              let reason = $3;
              emit(new Error(full_path, reason));
              return new Some(vfs);
            }
          }
        } else {
          delete$(path, vfs, emit);
          return create_stat(filter, depth, vfs.name, full_path, stat, emit);
        }
      } else {
        delete$(path, vfs, emit);
        return create_stat(filter, depth, vfs.name, full_path, stat, emit);
      }
    } else {
      delete$(path, vfs, emit);
      return new None();
    }
  } else {
    let $1 = $[0];
    if ($1 instanceof Eacces) {
      delete$(path, vfs, emit);
      return new None();
    } else if ($1 instanceof Enoent) {
      delete$(path, vfs, emit);
      return new None();
    } else {
      let reason = $1;
      emit(new Error(path, reason));
      return new Some(vfs);
    }
  }
}

function create_children(
  loop$filter,
  loop$depth,
  loop$path,
  loop$children,
  loop$oks,
  loop$emit
) {
  while (true) {
    let filter = loop$filter;
    let depth = loop$depth;
    let path = loop$path;
    let children = loop$children;
    let oks = loop$oks;
    let emit = loop$emit;
    if (children instanceof $Empty) {
      return $list.reverse(oks);
    } else {
      let first = children.head;
      let rest = children.tail;
      let $ = create(filter, depth, path, first, emit);
      if ($ instanceof Some) {
        let vfs = $[0];
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$children = rest;
        loop$oks = listPrepend(vfs, oks);
        loop$emit = emit;
      } else {
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$children = rest;
        loop$oks = oks;
        loop$emit = emit;
      }
    }
  }
}

function create(filter, depth, path, name, emit) {
  let full_path = $filepath.join(path, name);
  let $ = $simplifile.link_info(full_path);
  if ($ instanceof Ok) {
    let stat = $[0];
    return create_stat(filter, depth, name, full_path, stat, emit);
  } else {
    let $1 = $[0];
    if ($1 instanceof Eacces) {
      return new None();
    } else if ($1 instanceof Enoent) {
      return new None();
    } else {
      let reason = $1;
      emit(new Error(full_path, reason));
      return new None();
    }
  }
}

function create_stat(filter, depth, name, full_path, stat, emit) {
  let type_ = $simplifile.file_info_type(stat);
  return $bool.guard(
    !filter(type_, full_path),
    new None(),
    () => {
      if (type_ instanceof $simplifile.File) {
        emit(new Created(full_path));
        return new Some(new File(name, get_modkey(stat)));
      } else if (type_ instanceof $simplifile.Directory) {
        if (depth === 0) {
          emit(new Created(full_path));
          return new Some(new Folder(name, get_modkey(stat), toList([])));
        } else if (depth !== 0) {
          let $ = readdir(full_path);
          if ($ instanceof Ok) {
            let entries = $[0];
            let depth$1 = depth - 1;
            emit(new Created(full_path));
            let children = create_children(
              filter,
              depth$1,
              full_path,
              entries,
              toList([]),
              emit,
            );
            return new Some(new Folder(name, get_modkey(stat), children));
          } else {
            let $1 = $[0];
            if ($1 instanceof Eacces) {
              return new None();
            } else if ($1 instanceof Enoent) {
              return new None();
            } else {
              let reason = $1;
              emit(new Error(full_path, reason));
              return new None();
            }
          }
        } else {
          return new None();
        }
      } else {
        return new None();
      }
    },
  );
}

function step(options, emit, roots) {
  let max_depth$1;
  let filter$1;
  max_depth$1 = options.max_depth;
  filter$1 = options.filter;
  return $list.fold(
    roots,
    toList([]),
    (roots, _use1) => {
      let path;
      let vfs;
      path = _use1[0];
      vfs = _use1[1];
      if (vfs instanceof Some) {
        let vfs$1 = vfs[0];
        let new_vfs = diff(filter$1, max_depth$1, path, vfs$1, emit);
        return listPrepend([path, new_vfs], roots);
      } else {
        let new_vfs = create(filter$1, max_depth$1, path, "", emit);
        return listPrepend([path, new_vfs], roots);
      }
    },
  );
}

function init_children(
  loop$filter,
  loop$depth,
  loop$path,
  loop$children,
  loop$oks,
  loop$errors
) {
  while (true) {
    let filter = loop$filter;
    let depth = loop$depth;
    let path = loop$path;
    let children = loop$children;
    let oks = loop$oks;
    let errors = loop$errors;
    if (children instanceof $Empty) {
      return [$list.reverse(oks), errors];
    } else {
      let first = children.head;
      let rest = children.tail;
      let $ = init(filter, depth, path, first, errors);
      let $1 = $[0];
      if ($1 instanceof Some) {
        let errors$1 = $[1];
        let vfs = $1[0];
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$children = rest;
        loop$oks = listPrepend(vfs, oks);
        loop$errors = errors$1;
      } else {
        let errors$1 = $[1];
        loop$filter = filter;
        loop$depth = depth;
        loop$path = path;
        loop$children = rest;
        loop$oks = oks;
        loop$errors = errors$1;
      }
    }
  }
}

function init(filter, depth, path, name, errors) {
  let full_path = $filepath.join(path, name);
  let $ = $simplifile.link_info(full_path);
  if ($ instanceof Ok) {
    let stat = $[0];
    return init_stat(filter, depth, name, full_path, stat, errors);
  } else {
    let $1 = $[0];
    if ($1 instanceof Eacces) {
      return [new None(), errors];
    } else if ($1 instanceof Enoent) {
      return [new None(), errors];
    } else {
      let reason = $1;
      return [new None(), listPrepend([full_path, reason], errors)];
    }
  }
}

function init_stat(filter, depth, name, full_path, stat, errors) {
  let type_ = $simplifile.file_info_type(stat);
  return $bool.guard(
    !filter(type_, full_path),
    [new None(), errors],
    () => {
      if (type_ instanceof $simplifile.File) {
        return [new Some(new File(name, get_modkey(stat))), errors];
      } else if (type_ instanceof $simplifile.Directory) {
        if (depth === 0) {
          return [
            new Some(new Folder(name, get_modkey(stat), toList([]))),
            errors,
          ];
        } else if (depth !== 0) {
          let $ = readdir(full_path);
          if ($ instanceof Ok) {
            let entries = $[0];
            let depth$1 = depth - 1;
            let $1 = init_children(
              filter,
              depth$1,
              full_path,
              entries,
              toList([]),
              errors,
            );
            let children;
            let errors$1;
            children = $1[0];
            errors$1 = $1[1];
            return [
              new Some(new Folder(name, get_modkey(stat), children)),
              errors$1,
            ];
          } else {
            let $1 = $[0];
            if ($1 instanceof Eacces) {
              return [new None(), errors];
            } else if ($1 instanceof Enoent) {
              return [new None(), errors];
            } else {
              let reason = $1;
              return [new None(), listPrepend([full_path, reason], errors)];
            }
          }
        } else {
          return [new None(), toList([])];
        }
      } else {
        return [new None(), toList([])];
      }
    },
  );
}

/**
 * Create a child specification for running Polly under a supervisor.
 *
 * This lets you add Polly to your supervision tree, so she'll automatically
 * restart if something goes wrong. The supervisor will make sure she keeps
 * watching your files reliably!
 * Create a factory builder for dynamically starting multiple Polly watchers.
 *
 * This is useful when you want to spawn and manage multiple watchers at runtime,
 * each watching different paths with different options. The factory supervisor
 * handles starting, stopping, and supervising all your Polly instances!
 * 
 * @ignore
 */
function get_initial_roots(options) {
  let paths;
  let max_depth$1;
  let filter$1;
  let ignore_initial_missing$1;
  paths = options.paths;
  max_depth$1 = options.max_depth;
  filter$1 = options.filter;
  ignore_initial_missing$1 = options.ignore_initial_missing;
  return $bool.guard(
    isEqual(paths, toList([])),
    new Err(toList([])),
    () => {
      return $list.try_map(
        paths,
        (path) => {
          let $ = init(filter$1, max_depth$1, path, "", toList([]));
          let $1 = $[0];
          if ($1 instanceof Some) {
            let $2 = $[1];
            if ($2 instanceof $Empty) {
              let vfs = $1[0];
              return new Ok([path, new Some(vfs)]);
            } else {
              let errors = $2;
              return new Err(errors);
            }
          } else {
            let $2 = $[1];
            if ($2 instanceof $Empty) {
              if (ignore_initial_missing$1) {
                return new Ok([path, new None()]);
              } else {
                return new Err(toList([[path, new Enoent()]]));
              }
            } else {
              let errors = $2;
              return new Err(errors);
            }
          }
        },
      );
    },
  );
}

/**
 * Tell Polly to start watching all the specified directories for changes.
 *
 * The callbacks are called synchronously while collecting change events since
 * the last run. It is adviseable to move heavier cpu-bound tasks from this
 * callback into their own processes or threads.
 *
 * When running on the Erlang target, this spawns a new linked process.
 */
export function watch(options) {
  return $result.try$(
    get_initial_roots(options),
    (roots) => {
      let emit = (_capture) => { return broadcast(options.callbacks, _capture); };
      let stop$1 = repeatedly(
        options.interval,
        roots,
        (_capture) => { return step(options, emit, _capture); },
      );
      return new Ok(new Watcher(stop$1));
    },
  );
}
