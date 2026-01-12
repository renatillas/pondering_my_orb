import iv/internal/constants

/// Vectors are the low-level linear array-like structure.
/// We have the implementation in this module to maximise inlining.
///
/// Vectors use 1-based indexing because erlang tuples do!!
pub type Vector(item)

@external(erlang, "iv_ffi", "empty")
@external(javascript, "../../iv_ffi.mjs", "empty")
pub fn new() -> Vector(item)

@external(erlang, "iv_ffi", "singleton")
@external(javascript, "../../iv_ffi.mjs", "singleton")
pub fn singleton(item: item) -> Vector(item)

@external(erlang, "iv_ffi", "pair")
@external(javascript, "../../iv_ffi.mjs", "pair")
pub fn pair(first: item, second: item) -> Vector(item)

@external(erlang, "erlang", "append_element")
@external(javascript, "../../iv_ffi.mjs", "append")
pub fn append(xs: Vector(item), x: item) -> Vector(item)

@external(erlang, "iv_ffi", "prepend")
@external(javascript, "../../iv_ffi.mjs", "prepend")
pub fn prepend(xs: Vector(item), x: item) -> Vector(item)

@external(erlang, "iv_ffi", "drop_first")
@external(javascript, "../../iv_ffi.mjs", "drop_first")
pub fn drop_first(xs: Vector(item)) -> Vector(item)

@external(erlang, "iv_ffi", "drop_last")
@external(javascript, "../../iv_ffi.mjs", "drop_last")
pub fn drop_last(xs: Vector(item)) -> Vector(item)

// @external(erlang, "iv_ffi", "concat")
@external(javascript, "../../iv_ffi.mjs", "concat")
pub fn concat(a: Vector(item), b: Vector(item)) -> Vector(item) {
  fold(b, a, append)
}

@external(erlang, "iv_ffi", "concat_all")
@external(javascript, "../../iv_ffi.mjs", "concat_all")
pub fn concat_all(vectors: List(Vector(item))) -> Vector(item)

@external(erlang, "erlang", "setelement")
@external(javascript, "../../iv_ffi.mjs", "set1")
pub fn set(idx: Int, xs: Vector(item), x: item) -> Vector(item)

@external(erlang, "erlang", "tuple_size")
@external(javascript, "../../iv_ffi.mjs", "length")
pub fn length(xs: Vector(item)) -> Int

@external(erlang, "erlang", "element")
@external(javascript, "../../iv_ffi.mjs", "get1")
pub fn get(index_plus_one: Int, xs: Vector(item)) -> item

@external(erlang, "iv_ffi", "split1")
@external(javascript, "../../iv_ffi.mjs", "split1")
pub fn split(at: Int, xs: Vector(item)) -> #(Vector(item), Vector(item))

@external(erlang, "iv_ffi", "map")
@external(javascript, "../../iv_ffi.mjs", "map")
pub fn map(xs: Vector(a), fun: fn(a) -> b) -> Vector(b)

@external(erlang, "iv_ffi", "map_add")
pub fn map_add(xs: Vector(Int), delta: Int) -> Vector(Int) {
  map(xs, fn(x) { x + delta })
}

@external(erlang, "iv_ffi", "fold")
pub fn fold(
  over xs: Vector(item),
  from state: a,
  with fun: fn(a, item) -> a,
) -> a {
  let len = length(xs)
  fold_loop(xs, state, 1, len, fun)
}

@external(erlang, "iv_ffi", "fold_skip_last")
pub fn fold_skip_last(
  over xs: Vector(item),
  from state: a,
  with fun: fn(a, item) -> a,
) -> a {
  let len = length(xs)
  fold_loop(xs, state, 1, len - 1, fun)
}

@external(erlang, "iv_ffi", "fold_skip_first")
pub fn fold_skip_first(
  over xs: Vector(item),
  from state: a,
  with fun: fn(a, item) -> a,
) -> a {
  let len = length(xs)
  fold_loop(xs, state, 2, len, fun)
}

fn fold_loop(xs, state, idx, len, fun) {
  case idx <= len {
    True -> fold_loop(xs, fun(state, get(idx, xs)), idx + 1, len, fun)
    False -> state
  }
}

pub fn try_map(
  xs: Vector(a),
  fun: fn(a) -> Result(b, e),
) -> Result(Vector(b), e) {
  use result, item <- try_fold(xs, new())
  case fun(item) {
    Ok(mapped) -> Ok(append(result, mapped))
    Error(error) -> Error(error)
  }
}

pub fn index_map(xs: Vector(a), fun: fn(a, Int) -> b) -> Vector(b) {
  use result, item, index <- index_fold(xs, new())
  append(result, fun(item, index))
}

pub fn fold_right(
  xs: Vector(item),
  state: state,
  fun: fn(state, item) -> state,
) -> state {
  let len = length(xs)
  fold_right_loop(xs, state, len, fun)
}

fn fold_right_loop(xs, state, idx, fun) {
  case idx > 0 {
    True -> fold_right_loop(xs, fun(state, get(idx, xs)), idx - 1, fun)
    False -> state
  }
}

pub fn index_fold_right(
  xs: Vector(item),
  state: state,
  fun: fn(state, item, Int) -> state,
) -> state {
  let len = length(xs)
  index_fold_right_loop(xs, state, len, fun)
}

fn index_fold_right_loop(xs, state, idx, fun) {
  case idx > 0 {
    True ->
      index_fold_right_loop(xs, fun(state, get(idx, xs), idx), idx - 1, fun)
    False -> state
  }
}

pub fn index_fold(
  xs: Vector(item),
  state: state,
  fun: fn(state, item, Int) -> state,
) -> state {
  let len = length(xs)
  index_fold_loop(xs, state, 1, len, fun)
}

fn index_fold_loop(xs, state, idx, len, fun) {
  case idx <= len {
    True ->
      index_fold_loop(xs, fun(state, get(idx, xs), idx), idx + 1, len, fun)
    False -> state
  }
}

pub fn try_fold(
  xs: Vector(item),
  state: state,
  fun: fn(state, item) -> Result(state, error),
) -> Result(state, error) {
  let len = length(xs)
  try_fold_loop(xs, state, 1, len, fun)
}

fn try_fold_loop(xs, state, idx, len, fun) {
  case idx <= len {
    True ->
      case fun(state, get(idx, xs)) {
        Ok(state) -> try_fold_loop(xs, state, idx + 1, len, fun)
        Error(error) -> Error(error)
      }
    False -> Ok(state)
  }
}

pub fn find_map(xs, fun) {
  let len = length(xs)
  find_map_loop(xs, 1, len, fun)
}

fn find_map_loop(xs, idx, len, fun) {
  case idx <= len {
    True -> {
      let item = get(idx, xs)
      case fun(item) {
        Ok(_) as result -> result
        Error(_) -> find_map_loop(xs, idx + 1, len, fun)
      }
    }
    False -> constants.error_nil
  }
}

pub fn find_index(
  xs: Vector(a),
  fun: fn(a, Int) -> Result(b, Nil),
) -> Result(b, Nil) {
  let len = length(xs)
  find_index_loop(xs, 1, len, fun)
}

fn find_index_loop(xs, idx, len, fun) {
  case idx <= len {
    True ->
      case fun(get(idx, xs), idx) {
        Ok(_) as result -> result
        Error(Nil) -> find_index_loop(xs, idx + 1, len, fun)
      }
    False -> constants.error_nil
  }
}

pub fn find_last_index(
  xs: Vector(a),
  fun: fn(a, Int) -> Result(b, Nil),
) -> Result(b, Nil) {
  let len = length(xs)
  find_last_index_loop(xs, len, fun)
}

fn find_last_index_loop(xs, idx, fun) {
  case idx > 0 {
    True ->
      case fun(get(idx, xs), idx) {
        Ok(_) as result -> result
        Error(Nil) -> find_last_index_loop(xs, idx - 1, fun)
      }
    False -> constants.error_nil
  }
}
