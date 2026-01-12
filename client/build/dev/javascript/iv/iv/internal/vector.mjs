import { Ok } from "../../gleam.mjs";
import * as $constants from "../../iv/internal/constants.mjs";
import {
  empty as new$,
  singleton,
  pair,
  append,
  prepend,
  drop_first,
  drop_last,
  concat_all,
  set1 as set,
  length,
  get1 as get,
  split1 as split,
  map,
  concat,
} from "../../iv_ffi.mjs";

export {
  append,
  concat,
  concat_all,
  drop_first,
  drop_last,
  get,
  length,
  map,
  new$,
  pair,
  prepend,
  set,
  singleton,
  split,
};

export function map_add(xs, delta) {
  return map(xs, (x) => { return x + delta; });
}

function fold_loop(loop$xs, loop$state, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      loop$xs = xs;
      loop$state = fun(state, get(idx, xs));
      loop$idx = idx + 1;
      loop$len = len;
      loop$fun = fun;
    } else {
      return state;
    }
  }
}

export function fold(xs, state, fun) {
  let len = length(xs);
  return fold_loop(xs, state, 1, len, fun);
}

export function fold_skip_last(xs, state, fun) {
  let len = length(xs);
  return fold_loop(xs, state, 1, len - 1, fun);
}

export function fold_skip_first(xs, state, fun) {
  let len = length(xs);
  return fold_loop(xs, state, 2, len, fun);
}

function fold_right_loop(loop$xs, loop$state, loop$idx, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let fun = loop$fun;
    let $ = idx > 0;
    if ($) {
      loop$xs = xs;
      loop$state = fun(state, get(idx, xs));
      loop$idx = idx - 1;
      loop$fun = fun;
    } else {
      return state;
    }
  }
}

export function fold_right(xs, state, fun) {
  let len = length(xs);
  return fold_right_loop(xs, state, len, fun);
}

function index_fold_right_loop(loop$xs, loop$state, loop$idx, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let fun = loop$fun;
    let $ = idx > 0;
    if ($) {
      loop$xs = xs;
      loop$state = fun(state, get(idx, xs), idx);
      loop$idx = idx - 1;
      loop$fun = fun;
    } else {
      return state;
    }
  }
}

export function index_fold_right(xs, state, fun) {
  let len = length(xs);
  return index_fold_right_loop(xs, state, len, fun);
}

function index_fold_loop(loop$xs, loop$state, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      loop$xs = xs;
      loop$state = fun(state, get(idx, xs), idx);
      loop$idx = idx + 1;
      loop$len = len;
      loop$fun = fun;
    } else {
      return state;
    }
  }
}

export function index_fold(xs, state, fun) {
  let len = length(xs);
  return index_fold_loop(xs, state, 1, len, fun);
}

export function index_map(xs, fun) {
  return index_fold(
    xs,
    new$(),
    (result, item, index) => { return append(result, fun(item, index)); },
  );
}

function try_fold_loop(loop$xs, loop$state, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let state = loop$state;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      let $1 = fun(state, get(idx, xs));
      if ($1 instanceof Ok) {
        let state$1 = $1[0];
        loop$xs = xs;
        loop$state = state$1;
        loop$idx = idx + 1;
        loop$len = len;
        loop$fun = fun;
      } else {
        return $1;
      }
    } else {
      return new Ok(state);
    }
  }
}

export function try_fold(xs, state, fun) {
  let len = length(xs);
  return try_fold_loop(xs, state, 1, len, fun);
}

export function try_map(xs, fun) {
  return try_fold(
    xs,
    new$(),
    (result, item) => {
      let $ = fun(item);
      if ($ instanceof Ok) {
        let mapped = $[0];
        return new Ok(append(result, mapped));
      } else {
        return $;
      }
    },
  );
}

function find_map_loop(loop$xs, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      let item = get(idx, xs);
      let $1 = fun(item);
      if ($1 instanceof Ok) {
        return $1;
      } else {
        loop$xs = xs;
        loop$idx = idx + 1;
        loop$len = len;
        loop$fun = fun;
      }
    } else {
      return $constants.error_nil;
    }
  }
}

export function find_map(xs, fun) {
  let len = length(xs);
  return find_map_loop(xs, 1, len, fun);
}

function find_index_loop(loop$xs, loop$idx, loop$len, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let idx = loop$idx;
    let len = loop$len;
    let fun = loop$fun;
    let $ = idx <= len;
    if ($) {
      let $1 = fun(get(idx, xs), idx);
      if ($1 instanceof Ok) {
        return $1;
      } else {
        loop$xs = xs;
        loop$idx = idx + 1;
        loop$len = len;
        loop$fun = fun;
      }
    } else {
      return $constants.error_nil;
    }
  }
}

export function find_index(xs, fun) {
  let len = length(xs);
  return find_index_loop(xs, 1, len, fun);
}

function find_last_index_loop(loop$xs, loop$idx, loop$fun) {
  while (true) {
    let xs = loop$xs;
    let idx = loop$idx;
    let fun = loop$fun;
    let $ = idx > 0;
    if ($) {
      let $1 = fun(get(idx, xs), idx);
      if ($1 instanceof Ok) {
        return $1;
      } else {
        loop$xs = xs;
        loop$idx = idx - 1;
        loop$fun = fun;
      }
    } else {
      return $constants.error_nil;
    }
  }
}

export function find_last_index(xs, fun) {
  let len = length(xs);
  return find_last_index_loop(xs, len, fun);
}
