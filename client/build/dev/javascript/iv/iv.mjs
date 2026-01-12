import * as $int from "../gleam_stdlib/gleam/int.mjs";
import * as $list from "../gleam_stdlib/gleam/list.mjs";
import * as $yielder from "../gleam_yielder/gleam/yielder.mjs";
import {
  Ok,
  toList,
  prepend as listPrepend,
  CustomType as $CustomType,
  remainderInt,
  divideInt,
  isEqual,
} from "./gleam.mjs";
import * as $builder from "./iv/internal/builder.mjs";
import * as $constants from "./iv/internal/constants.mjs";
import * as $iterator from "./iv/internal/iterator.mjs";
import * as $node from "./iv/internal/node.mjs";
import { branch_bits } from "./iv/internal/node.mjs";
import * as $vector from "./iv/internal/vector.mjs";

class Empty extends $CustomType {}

class Array extends $CustomType {
  constructor(shift, root) {
    super();
    this.shift = shift;
    this.root = root;
  }
}

function array(shift, nodes) {
  let $ = $vector.length(nodes);
  if ($ === 0) {
    return new Empty();
  } else if ($ === 1) {
    return new Array(shift, $vector.get(1, nodes));
  } else {
    let shift$1 = shift + branch_bits;
    return new Array(shift$1, $node.branch(shift$1, nodes));
  }
}

/**
 * Returns a new empty array.
 *
 * ```gleam
 * new()
 * // --> from_list([])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function new$() {
  return new Empty();
}

/**
 * Returns the given item wrapped in a list.
 *
 * ```gleam
 * wrap(42)
 * // --> from_list([42])
 *
 * wrap(from_list([1, 2, 3]))
 * // --> from_list([from_list([1, 2, 3])])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function wrap(item) {
  return new Array(0, new $node.Leaf($vector.singleton(item)));
}

/**
 * Converts the given list to an array.
 *
 * ```gleam
 * length(from_list([1, 2, 3]))
 * // --> 3
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function from_list(list) {
  let $ = (() => {
    let _pipe = list;
    let _pipe$1 = $list.fold(_pipe, $builder.new$(), $builder.push);
    return $builder.build(_pipe$1);
  })();
  if ($ instanceof Ok) {
    let shift = $[0][0];
    let nodes = $[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Convert the given list to an array that contains all items in the reverse
 * order from the original list.
 *
 * Equivalent to `iv.from_list(list.reverse(items))`.
 *
 * This is useful as the last step in a tail-recursive algorithm building up a
 * list as an intermediary. Instead of calling `list.reverse` and then
 * converting the final list to an array, it's faster to use this function
 * instead!
 *
 * ```gleam
 * from_reverse_list([1, 2, 3])
 * // --> from_list([3, 2, 1])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function from_reverse_list(list) {
  let $ = (() => {
    let _pipe = list;
    let _pipe$1 = $list.fold(_pipe, $builder.reverse(), $builder.push);
    return $builder.build(_pipe$1);
  })();
  if ($ instanceof Ok) {
    let shift = $[0][0];
    let nodes = $[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Consume the given yielder, collecting all elements into a new array.
 *
 * ```gleam
 * from_yielder(
 *   yielder.range(1, 3)
 *   |> yielder.cycle()
 *   |> yielder.take(10)
 * )
 * // --> from_list([1, 2, 3, 1, 2, 3, 1, 2, 3, 1])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function from_yielder(source) {
  let $ = (() => {
    let _pipe = source;
    let _pipe$1 = $yielder.fold(_pipe, $builder.new$(), $builder.push);
    return $builder.build(_pipe$1);
  })();
  if ($ instanceof Ok) {
    let shift = $[0][0];
    let nodes = $[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Return a yielder iterating through an array.
 *
 * Yielders are more efficient then repeatetly querying the index, but slower
 * than using more specialised functions like [each](#each) or [fold](#fold).
 * Only use this if you need to pause or iterate through many arrays at once.
 *
 * ```gleam
 * to_yielder(from_list([1, 2, 3]))
 * |> yielder.cycle
 * |> yielder.take(10)
 * |> yielder.to_list
 * // --> [1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function to_yielder(array) {
  if (array instanceof Empty) {
    return $yielder.empty();
  } else {
    let root = array.root;
    return $iterator.new$(root);
  }
}

function initialise_loop(loop$idx, loop$length, loop$builder, loop$fun) {
  while (true) {
    let idx = loop$idx;
    let length = loop$length;
    let builder = loop$builder;
    let fun = loop$fun;
    let $ = idx < length;
    if ($) {
      loop$idx = idx + 1;
      loop$length = length;
      loop$builder = $builder.push(builder, fun(idx));
      loop$fun = fun;
    } else {
      return $builder.build(builder);
    }
  }
}

/**
 * Create a list using a constructor function for each element.
 * The function receives the current index as an input.
 *
 * ```gleam
 * initialise(5, fn(i) { i * 2 })
 * // --> from_list([0, 2, 4, 6, 8])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function initialise(length, fun) {
  let $ = initialise_loop(0, length, $builder.new$(), fun);
  if ($ instanceof Ok) {
    let shift = $[0][0];
    let nodes = $[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Build an array by repeating the given element a number of times.
 *
 * ```gleam
 * repeat("hi", times: 3)
 * // --> from_list(["hi", "hi", "hi"])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function repeat(item, times) {
  return initialise(times, (_) => { return item; });
}

/**
 * Creates a list of ints ranging from a given start and finish.
 *
 * ```gleam
 * range(1, 3)
 * // --> from_list([1, 2, 3])
 *
 * range(10, 1)
 * // --> from_list([10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function range(start, stop) {
  let $ = start <= stop;
  if ($) {
    return initialise((stop - start) + 1, (x) => { return x + start; });
  } else {
    return initialise((start - stop) + 1, (x) => { return start - x; });
  }
}

/**
 * Check whether or not an array is empty.
 *
 * ```gleam
 * is_empty(from_list([]))
 *  // --> True
 *
 * is_empty(from_list([1, 2, 3]))
 * // --> False
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function is_empty(array) {
  if (array instanceof Empty) {
    return true;
  } else {
    return false;
  }
}

/**
 * Returns the number of items in the array.
 *
 * ```gleam
 * size(from_list([]))
 * // --> 0
 *
 * size(from_list(["hello", "joe"]))
 * // --> 2
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function size(array) {
  if (array instanceof Empty) {
    return 0;
  } else {
    let root = array.root;
    return $node.size(root);
  }
}

/**
 * Returns the number of items in the array.
 *
 * ```gleam
 * length(from_list([]))
 * // --> 0
 *
 * length(from_list(["hello", "joe"]))
 * // --> 2
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function length(array) {
  return size(array);
}

/**
 * Checks whether or not two arrays are equal. Arrays are considered to be
 * equal if they have the same length, and their elements are pairwise equal.
 *
 * **Important:** Always use this function instead of the `==` operator! \
 * Arrays containing the same elements can have different runtime representations.
 *
 * ```gleam
 * equal(from_list([1, 2, 3]), initialise(3, fn(x) { x + 1 }))
 * // --> True
 *
 * equal(from_list([1, 2, 3]), from_list([1]))
 * // --> False
 *
 * equal(from_list([1, 2, 3]), from_list([1, 2, 4]))
 * // --> False
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function equal(a, b) {
  let $ = size(a) === size(b);
  if ($) {
    let _pipe = $yielder.map2(
      to_yielder(a),
      to_yielder(b),
      (a, b) => { return isEqual(a, b); },
    );
    return $yielder.all(_pipe, (a) => { return a; });
  } else {
    return $;
  }
}

/**
 * Get the element at a specific index.
 *
 * Arrays are 0-based, so the first element is at index `0`, the second is at
 * index `1`, the third is at index `2`, and so forth, up to `length - 1`.
 *
 * ```gleam
 * let array = from_list(["trans", "rights", "are", "human", "rights"])
 *
 * get(from: array, at: 1)
 * // --> Ok("rights")
 *
 * get(from: array, at: 3)
 * // --> Ok("human")
 *
 * get(from: array, at: -1)
 * // --> Error(Nil)
 *
 * get(from: array, at: 5)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function get(array, index) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = (0 <= index) && (index < $node.size(root));
    if ($) {
      return new Ok($node.get(root, shift, index));
    } else {
      return $constants.error_nil;
    }
  }
}

/**
 * Get the first element from the start of the array, if there is one.
 *
 * ```gleam
 * first(new())
 * // --> Error(Nil)
 *
 * first(from_list([1, 2, 3]))
 * // --> Ok(1)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function first(array) {
  return get(array, 0);
}

/**
 * Get the last element in the array, if there is one.
 *
 * ```gleam
 * last(new())
 * // --> Error(Nil)
 *
 * last(from_list([1]))
 * // --> Ok(1)
 *
 * last(from_list([1, 2, 3]))
 * // --> Ok(3)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function last(array) {
  return get(array, size(array) - 1);
}

/**
 * Get the element at a specific index. If the index is negative, get the
 * nth-last element instead.
 *
 * ```gleam
 * let array = from_list(["trans", "rights", "are", "human", "rights"])
 *
 * at(from: array, at: 1)
 * // --> Ok("rights")
 *
 * at(from: array, at: 3)
 * // --> Ok("human")
 *
 * at(from: array, at: -1)
 * // --> Ok("rights")
 *
 * at(from: array, at: 5)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function at(array, index) {
  let $ = index >= 0;
  if ($) {
    return get(array, index);
  } else {
    return get(array, size(array) + index);
  }
}

/**
 * Get the element at a specific index, or a default value if the index is out
 * of range.
 *
 * Arrays are 0-based, so the first element is at index `0`, the second is at
 * index `1`, the third is at index `2`, and so forth, up to `length - 1`.
 *
 * ```gleam
 * let array = from_list(["trans", "rights", "are", "human", "rights"])
 *
 * get_or_default(from: array, at: 1, or: "")
 * // --> "rights"
 *
 * get_or_default(from: array, at: 3, or: "")
 * // --> "human"
 *
 * get_or_default(from: array, at: -1, or: "")
 * // --> ""
 *
 * get_or_default(from: array, at: 5, or: "")
 * // --> ""
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function get_or_default(array, index, default$) {
  if (array instanceof Empty) {
    return default$;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = (0 <= index) && (index < $node.size(root));
    if ($) {
      return $node.get(root, shift, index);
    } else {
      return default$;
    }
  }
}

/**
 * Find the first element for which the given function returns `Ok(value)`,
 * and return the wrapped value.
 *
 * ```gleam
 * find_map(from_list([[], [2], [3]]), list.first)
 * // --> Ok(2)
 *
 * find_map(from_list([[], []]), list.first)
 * // --> Error(Nil)
 *
 * find_map(new(), first)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function find_map(array, is_desired) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    let root = array.root;
    return $node.find_map(root, is_desired);
  }
}

/**
 * Find the first element from the start  of the array for which the given
 * function returns `True`, and return it.
 *
 * ```gleam
 * find(from_list([1, 2, 3, 4]), fn(x) { x > 2 })
 * // --> Ok(3)
 *
 * find(from_list([1, 2, 3, 4]), fn(x) { x > 4 })
 * // --> Error(Nil)
 *
 * find(new(), fn(_) { True })
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function find(array, is_desired) {
  return find_map(
    array,
    (item) => {
      let $ = is_desired(item);
      if ($) {
        return new Ok(item);
      } else {
        return $constants.error_nil;
      }
    },
  );
}

/**
 * Check if a function returns `True` for at least one of the elements
 * in the array.
 *
 * ```gleam
 * any(new(), int.is_even)
 * // --> False
 *
 * any(from_list([1, 3, 5]), int.is_even)
 * // --> False
 *
 * any(from_list([1, 2, 3]), int.is_even)
 * // --> True
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function any(array, predicate) {
  let $ = find(array, predicate);
  if ($ instanceof Ok) {
    return true;
  } else {
    return false;
  }
}

/**
 * Check if a fuction returns `True` for every element in the array.
 *
 * ```gleam
 * all(new(), int.is_even)
 *  // --> True
 *
 * all(from_list([1, 2, 3]), int.is_even)
 * // --> False
 *
 * all(from_list([2, 4, 6]), int.is_even)
 * // --> True
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function all(array, predicate) {
  return !any(array, (item) => { return !predicate(item); });
}

/**
 * Linearly search through the array to check if it contains an item.
 *
 * ```gleam
 * contains(in: new(), any: 0)
 * // --> False
 *
 * contains(in: from_list([1, 2, 3]), any: 2)
 * // --> True
 *
 * contains(in: from_list([1, 2, 3]), any: 5)
 * // --> False
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function contains(array, item) {
  return any(array, (other) => { return isEqual(other, item); });
}

/**
 * Return the index of the first element in the array for which the given
 * function returns `True`, or `Error(Nil)` if no such element can be found.
 *
 * ```gleam
 * find_index(from_list([4, 5, 6, 5]), fn(x) { x > 5 })
 * // --> Ok(2)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function find_index(array, is_desired) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    let shift = array.shift;
    let root = array.root;
    return $node.find_index(shift, 0, root, is_desired);
  }
}

/**
 * Return the index of the first occurrence of the given element in the array,
 * or `Error(Nil)` if the array doesn't contain the element.
 *
 * ```gleam
 * index_of(from_list([4, 5, 6, 5]), of: 5)
 * // --> Ok(1)
 *
 * index_of(from_list([4, 5, 6, 5]), of: 1)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function index_of(array, item) {
  return find_index(array, (other) => { return isEqual(other, item); });
}

/**
 * Return the index of the last element in the array for which the given
 * function returns `True`, or `Error(Nil)` if no such element can be found.
 *
 * ```gleam
 * find_last_index(from_list([4, 5, 6, 7]), fn(x) { x > 5 })
 * // --> Ok(3)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function find_last_index(array, is_desired) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    let shift = array.shift;
    let root = array.root;
    return $node.find_last_index(shift, 0, root, is_desired);
  }
}

/**
 * Return the index of the last occurrence of the given element in the array,
 * or `Error(Nil)` if the array doesn't contain the element.
 *
 * ```gleam
 * last_index_of(from_list([4, 5, 6, 5]), of: 5)
 * // --> Ok(3)
 *
 * last_index_of(from_list([4, 5, 6, 5]), of: 1)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function last_index_of(array, item) {
  return find_last_index(array, (other) => { return isEqual(other, item); });
}

/**
 * Update the element at a given index and return a new array, or return
 * `Error(Nil)` if the index cannot be found in the array.
 *
 * This is slightly more efficient than `get`-ing and then `set`-ing the element.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> update(at: 1, with: fn(x) { x * 2 })
 * // --> Ok(from_list([1, 4, 3]))
 *
 * from_list([1, 2, 3]) |> update(at: -1, with: fn(x) { x + 1 })
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function update(array, index, fun) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = (0 <= index) && (index < $node.size(root));
    if ($) {
      return new Ok(new Array(shift, $node.update(shift, root, index, fun)));
    } else {
      return $constants.error_nil;
    }
  }
}

/**
 * Store a new value at a given index and return the new array, or `Error(Nil)`
 * if the index cannot be found in the array.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> set(at: 1, to: 50)
 * // --> Ok(from_list([1, 50, 3]))
 *
 * from_list([1, 2, 3]) |> set(at: -1, to: 50)
 * // --> Error(Nil)
 *
 * from_list([]) |> set(at: 0, to: 1)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function set(array, index, item) {
  return update(array, index, (_) => { return item; });
}

/**
 * Update the element at a given index and return a new array, or return the
 * given array unchanged if the index cannot be found in the array.
 *
 * This is more efficient than `get`-ing and then `try_set`-ing the element.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> try_update(at: 1, with: fn(x) { x * 2 })
 * // --> from_list([1, 4, 3])
 *
 * from_list([1, 2, 3]) |> try_update(at: -1, with: fn(x) { x + 1 })
 * // --> from_list([1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_update(array, index, fun) {
  if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = (0 <= index) && (index < $node.size(root));
    if ($) {
      return new Array(shift, $node.update(shift, root, index, fun));
    } else {
      return array;
    }
  }
}

/**
 * Store a new value at a given index and return the new array, or return the
 * given array unchanged if the index cannot be found.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> try_set(at: 1, to: 50)
 * // --> from_list([1, 50, 3])
 *
 * from_list([1, 2, 3]) |> try_set(at: -1, to: 50)
 * // --> from_list([1, 2, 3])
 *
 * from_list([]) |> try_set(at: 0, to: 1)
 * // --> from_list([])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_set(array, index, item) {
  return try_update(array, index, (_) => { return item; });
}

/**
 * Remove the element at a given index by swapping it with the last element,
 * then removing the last element. This is more efficient than `try_delete` but
 * does not preserve the order of elements. If the index does not exist, return
 * the array unchanged.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3, 4]) |> try_swap_delete(at: 1)
 * // --> from_list([1, 4, 3])
 *
 * from_list([1, 2, 3]) |> try_swap_delete(at: 3)
 * // --> from_list([1, 2, 3])
 *
 * from_list([]) |> try_swap_delete(at: 0)
 * // --> from_list([])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_swap_delete(array, index) {
  if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    let size$1 = $node.size(root);
    let $ = (0 <= index) && (index < size$1);
    if ($) {
      let $1 = $node.split(shift, root, size$1 - 1);
      if ($1 instanceof $node.Split) {
        let prefix = $1.prefix;
        let prefix_shift = $1.prefix_shift;
        let suffix = $1.suffix;
        let suffix_shift = $1.suffix_shift;
        let $2 = index === (size$1 - 1);
        if ($2) {
          return new Array(prefix_shift, prefix);
        } else {
          let last$1 = $node.get(suffix, suffix_shift, 0);
          let _pipe = prefix;
          let _pipe$1 = ((_capture) => {
            return $node.update(
              prefix_shift,
              _capture,
              index,
              (_) => { return last$1; },
            );
          })(_pipe);
          return ((_capture) => { return new Array(prefix_shift, _capture); })(
            _pipe$1,
          );
        }
      } else {
        return new Empty();
      }
    } else {
      return array;
    }
  }
}

/**
 * Remove the element at a given index by swapping it with the last element,
 * then removing the last element. This is more efficient than `delete` but
 * does not preserve the order of elements.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3, 4]) |> swap_delete(at: 1)
 * // --> Ok(from_list([1, 4, 3]))
 *
 * from_list([1, 2, 3]) |> swap_delete(at: 3)
 * // --> Error(Nil)
 *
 * from_list([]) |> swap_delete(at: 0)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function swap_delete(array, index) {
  let $ = (0 <= index) && (index < size(array));
  if ($) {
    return new Ok(try_swap_delete(array, index));
  } else {
    return $constants.error_nil;
  }
}

/**
 * Concatenate two arrays.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * concat(from_list([1, 2, 3]), from_list([4, 5, 6]))
 * // --> from_list([1, 2, 3, 4, 5, 6])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function concat(left, right) {
  if (left instanceof Empty) {
    return right;
  } else if (right instanceof Empty) {
    return left;
  } else {
    let shift1 = left.shift;
    let root1 = left.root;
    let shift2 = right.shift;
    let root2 = right.root;
    let _block;
    let $ = shift1 >= shift2;
    if ($) {
      _block = shift1;
    } else {
      _block = shift2;
    }
    let max_shift = _block;
    let _block$1;
    let $1 = $node.concat(root1, shift1, root2, shift2);
    if ($1 instanceof $node.OneNode) {
      let root = $1.node;
      _block$1 = $vector.singleton(root);
    } else {
      let full = $1.full;
      let partial = $1.partial;
      _block$1 = $vector.pair(full, partial);
    }
    let roots = _block$1;
    return array(max_shift, roots);
  }
}

/**
 * Direct concat tries to insert nodes into free slots without rebalancing.
 * This is efficient for append/prepend operations where one side is dense.
 * Falls back to regular concat when there are no free slots.
 * 
 * @ignore
 */
function direct_concat(left, right) {
  if (left instanceof Empty) {
    return right;
  } else if (right instanceof Empty) {
    return left;
  } else {
    let left_shift = left.shift;
    let left$1 = left.root;
    let right_shift = right.shift;
    let right$1 = right.root;
    let _block;
    let $ = left_shift > right_shift;
    if ($) {
      _block = left_shift;
    } else {
      _block = right_shift;
    }
    let shift = _block;
    let $1 = $node.direct_concat(left_shift, left$1, right_shift, right$1);
    if ($1 instanceof $node.Concatenated) {
      let root = $1.merged;
      return new Array(shift, root);
    } else {
      let left$2 = $1.left;
      let right$2 = $1.right;
      return array(shift, $vector.pair(left$2, right$2));
    }
  }
}

/**
 * Add an element to the end of an array.
 *
 * ```gleam
 * from_list(["hello"]) |> append("joe")
 * // --> from_list(["hello", "joe"])
 *
 * from_list([1, 2, 3]) |> append(4) |> append(0)
 * // --> from_list([1, 2, 3, 4, 0])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function append(array, item) {
  return direct_concat(array, wrap(item));
}

/**
 * Add all elements in a list to the end of the array.
 *
 * This more efficient than `append`-ing all elements individually.
 *
 * This function runs in _O(n)_ time, only depending on the size of the appended list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> append_list([4, 0])
 * // --> from_list([1, 2, 3, 4, 0])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function append_list(array, items) {
  return direct_concat(array, from_list(items));
}

/**
 * Add all elements in a list to the end of the array, in reverse order.
 *
 * This is more efficient than reversing the list first and then `append`-ing
 * all the elements.
 *
 * This is useful in tail-recursive algorithms to first build-up a intermediary
 * list instead of appending all elements immediately.
 *
 * This function runs in _O(n)_ time, only depending on the size of the appended list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> append_reverse_list([4, 0])
 * // --> from_list([1, 2, 3, 0, 4])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function append_reverse_list(array, items) {
  return direct_concat(array, from_reverse_list(items));
}

/**
 * Add an element to the start of the array, making it the first element.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list(["joe"]) |> prepend("hello")
 * // --> from_list(["hello", "joe"])
 *
 * from_list([1, 2, 3]) |> prepend(4) |> prepend(0)
 * // --> from_list([0, 4, 1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function prepend(array, item) {
  return direct_concat(wrap(item), array);
}

/**
 * Add many elements to the start of the array, in the same order they appear
 * in the list.
 *
 * This is more efficient than inserting all elements individually.
 *
 * This function runs in _O(n)_ time, only depending on the size of the prepended list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> prepend_list([4, 5, 6])
 * // --> from_list([4, 5, 6, 1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function prepend_list(array, items) {
  return direct_concat(from_list(items), array);
}

/**
 * Add many elements to the start of the array, in the reverse order they appear
 * in the list.
 *
 * This is more efficient than reversing the list first and then prepending it.
 *
 * This is useful in tail-recursive algorithms to first build-up a intermediary
 * list instead of prepending all elements immediately.
 *
 * This function runs in _O(n)_ time, only depending on the size of the prepended list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> prepend_list([4, 5, 6])
 * // --> from_list([6, 5, 4, 1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function prepend_reverse_list(array, items) {
  return direct_concat(from_reverse_list(items), array);
}

/**
 * Concatenate many array, joining them up to form a single array.
 *
 * This function runs in _O(n)_ time, only depending on the number of arrays.
 *
 * ```gleam
 * concat_list([from_list([1]), new(), from_list([2, 3])])
 * // --> from_list([1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function concat_list(arrays) {
  return $list.fold(arrays, new Empty(), concat);
}

/**
 * Split an array in two before the given index.
 *
 * If the list is not long enough to have the given index the before list will
 * be the input list, and the after list will be empty.
 *
 * ```gleam
 * split(from_list([6, 7, 8, 9]), at: 0)
 * // --> #(new(), from_list([6, 7, 8, 9]))
 *
 * split(from_list([6, 7, 8, 9]), at: 2)
 * // --> #(from_list([6, 7]), from_list([8, 9]))
 *
 * split(from_list([6, 7, 8, 9]), at: 4)
 * // --> #(from_list([6, 7, 8, 9]), new())
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function split(array, index) {
  if (array instanceof Empty) {
    return [new Empty(), new Empty()];
  } else if (index <= 0) {
    return [new Empty(), array];
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = $node.size(root);
    let length$1 = $;
    if (index >= length$1) {
      return [array, new Empty()];
    } else {
      let $1 = $node.split(shift, root, index);
      if ($1 instanceof $node.Split) {
        let prefix = $1.prefix;
        let prefix_shift = $1.prefix_shift;
        let suffix = $1.suffix;
        let suffix_shift = $1.suffix_shift;
        let prefix$1 = new Array(prefix_shift, prefix);
        let suffix$1 = new Array(suffix_shift, suffix);
        return [prefix$1, suffix$1];
      } else {
        return [new Empty(), array];
      }
    }
  }
}

/**
 * Insert an element at an index into the array, moving all existing elements.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * new() |> insert(at: 0, this: "hi")
 * // --> Ok(from_list(["hi"]))
 *
 * from_list([1, 2, 3]) |> insert(at: 1, this: 50)
 * // --> Ok(from_list([1, 50, 2, 3]))
 *
 * from_list([1, 2, 3]) |> insert(at: 3, this: 4)
 * // --> Ok(from_list([1, 2, 3, 4]))
 *
 * from_list([1, 2, 3]) |> insert(at: 5, this: 100)
 * // --> Error(Nil)
 *
 * from_list([1, 2, 3]) |> insert(at: -1, this: 0)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function insert(array, index, item) {
  let $ = size(array);
  let len = $;
  if ((0 <= index) && (index <= len)) {
    let $1 = split(array, index);
    let before;
    let after;
    before = $1[0];
    after = $1[1];
    return new Ok(concat(direct_concat(before, wrap(item)), after));
  } else {
    return $constants.error_nil;
  }
}

/**
 * Insert an element at an index into the array, moving all existing elements.
 * If the index is less than `0` prepend, and if it's greater than the number
 * of elements in the array append instead.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * new() |> insert_clamped(at: 0, this: "hi")
 * // --> from_list(["hi"])
 *
 * from_list([1, 2, 3]) |> insert_clamped(at: 1, this: 50)
 * // --> from_list([1, 50, 2, 3])
 *
 * from_list([1, 2, 3]) |> insert_clamped(at: 3, this: 4)
 * // --> from_list([1, 2, 3, 4])
 *
 * from_list([1, 2, 3]) |> insert_clamped(at: 5, this: 100)
 * // --> from_list([1, 2, 3, 100])
 *
 * from_list([1, 2, 3]) |> insert(at: -1, this: 0)
 * // --> from_list([0, 1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function insert_clamped(array, index, item) {
  let $ = size(array);
  if (index <= 0) {
    return prepend(array, item);
  } else {
    let len = $;
    if (index >= len) {
      return append(array, item);
    } else {
      let $1 = split(array, index);
      let before;
      let after;
      before = $1[0];
      after = $1[1];
      return concat(direct_concat(before, wrap(item)), after);
    }
  }
}

/**
 * Insert all elements in a given list to the array at a specific index,
 * in the same order they appear in the list.
 *
 * This is more efficient than inserting all elements individually.
 *
 * This function runs in _O(n)_ time, only depending on the size of the inserted list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> insert_list(at: 1, these: [34, 35])
 * // --> Ok(from_list([1, 34, 35, 2, 3]))
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function insert_list(array, index, items) {
  let $ = size(array);
  let len = $;
  if ((0 <= index) && (index <= len)) {
    let $1 = split(array, index);
    let before;
    let after;
    before = $1[0];
    after = $1[1];
    return new Ok(concat(direct_concat(before, from_list(items)), after));
  } else {
    return $constants.error_nil;
  }
}

/**
 * Insert elements at an index into the array, moving all existing elements.
 * If the index is less than `0` prepend, and if it's greater than the number
 * of elements in the array append instead.
 *
 * This is more efficient than inserting all elements individually.
 *
 * This function runs in _O(n)_ time, only depending on the size of the inserted list.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> insert_list_clamped(at: 1, these: [34, 35])
 * // --> from_list([1, 34, 35, 2, 3])
 *
 * from_list([1, 2, 3]) |> insert_list_clamped(at: 100, these: [100, 101])
 * // --> from_list([1, 2, 3, 100, 101])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function insert_list_clamped(array, index, items) {
  let $ = size(array);
  if (index <= 0) {
    return prepend_list(array, items);
  } else {
    let len = $;
    if (index >= len) {
      return append_list(array, items);
    } else {
      let $1 = split(array, index);
      let before;
      let after;
      before = $1[0];
      after = $1[1];
      return concat(direct_concat(before, from_list(items)), after);
    }
  }
}

/**
 * Replace a slice using a function, returning the new elements.
 *
 * The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3, 4]) |> splice(at: 1, replace: 2, with: fn(slice) {
 *   map(slice, fn(x) { x * 2 })
 * })
 * // --> Ok(from_list([1, 4, 6, 4]))
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function splice(array, index, count, replacer) {
  let $ = ((0 <= index) && (0 <= count)) && ((index + count) <= size(array));
  if ($) {
    let $1 = split(array, index);
    let before;
    let after;
    before = $1[0];
    after = $1[1];
    let $2 = split(after, count);
    let replace$1;
    let after$1;
    replace$1 = $2[0];
    after$1 = $2[1];
    return new Ok(concat(direct_concat(before, replacer(replace$1)), after$1));
  } else {
    return $constants.error_nil;
  }
}

/**
 * Replace a slice with a different array.
 *
 * The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3, 4]) |> replace(at: 1, replace: 2, with: from_list([7, 8, 9]))
 * // --> Ok(from_list([1, 7, 8, 9, 4]))
 *
 * from_list([1, 2, 3]) |> replace(at: 2, replace: 1, with: from_list([7, 8, 9]))
 * // --> Ok(from_list([1, 2, 7, 8, 9]))
 *
 * from_list([1, 2, 3]) |> replace(at: 2, replace: 2, with: from_list([8, 8, 9]))
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function replace(array, index, count, replacements) {
  return splice(array, index, count, (_) => { return replacements; });
}

/**
 * Remove up to `n` elements from the start of the array.
 *
 * If the array has less than `n` elements an empty array is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * drop_first(from_list([1, 2, 3, 4]), up_to: 2)
 * // --> from_list([3, 4])
 *
 * drop_first(from_list([1, 2, 3, 4]), up_to: 5)
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function drop_first(array, n) {
  if (n <= 0) {
    return array;
  } else if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = n < $node.size(root);
    if ($) {
      let $1 = $node.split(shift, root, n);
      if ($1 instanceof $node.Split) {
        let root$1 = $1.suffix;
        let suffix_shift = $1.suffix_shift;
        return new Array(suffix_shift, root$1);
      } else {
        return array;
      }
    } else {
      return new Empty();
    }
  }
}

/**
 * Return up to the first `n` elements from the start of the array.
 *
 * If the array has less than `n` elements, the original array is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * take_first(from_list([6, 7, 8, 9]), up_to: 3)
 * // --> from_list([6, 7, 8])
 *
 * take_first(from_list([6, 7, 8, 9]), up_to: 10)
 * // --> from_list([6, 7, 8, 9])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function take_first(array, n) {
  if (n <= 0) {
    return new Empty();
  } else if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = n < $node.size(root);
    if ($) {
      let $1 = $node.split(shift, root, n);
      if ($1 instanceof $node.Split) {
        let root$1 = $1.prefix;
        let prefix_shift = $1.prefix_shift;
        return new Array(prefix_shift, root$1);
      } else {
        return new Empty();
      }
    } else {
      return array;
    }
  }
}

/**
 * Remove the element at a given index, moving all subsequent elements
 * to the left.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> delete(at: 1)
 * // --> Ok(from_list([1, 3]))
 *
 * from_list([1, 2, 3]) |> delete(at: 3)
 * // --> Error(Nil)
 *
 * from_list([]) |> delete(at: 0)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function delete$(array, index) {
  let $ = (0 <= index) && (index < size(array));
  if ($) {
    return new Ok(
      concat(take_first(array, index), drop_first(array, index + 1)),
    );
  } else {
    return $constants.error_nil;
  }
}

/**
 * Remove the element at a given index, moving all subsequent elements
 * to the left. If the index does not exist, return the array unchanged.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * from_list([1, 2, 3]) |> try_delete(at: 1)
 * // --> from_list([1, 3])
 *
 * from_list([1, 2, 3]) |> try_delete(at: 3)
 * // --> from_list([1, 2, 3])
 *
 * from_list([]) |> try_delete(at: 0)
 * // --> from_list([])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_delete(array, index) {
  let $ = (0 <= index) && (index < size(array));
  if ($) {
    return concat(take_first(array, index), drop_first(array, index + 1));
  } else {
    return array;
  }
}

/**
 * Remove up to `n` elements from the end of the array.
 *
 * If the array has less than `n` elements an empty array is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * drop_last(from_list([1, 2, 3, 4]), up_to: 2)
 * // --> from_list([1, 2])
 *
 * drop_last(from_list([1, 2, 3, 4]), up_to: 5)
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function drop_last(array, n) {
  return take_first(array, size(array) - n);
}

/**
 * Return up `n` elements from the end of the array.
 *
 * If the array has less than `n` elements, the original array is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * take_last(from_list([6, 7, 8, 9]), up_to: 3)
 * // --> from_list([7, 8, 9])
 *
 * take_last(from_list([6, 7, 8, 9]), up_to: 10)
 * // --> from_list([6, 7, 8, 9])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function take_last(array, n) {
  return drop_first(array, size(array) - n);
}

function sized_chunk_loop(loop$array, loop$count, loop$chunks) {
  while (true) {
    let array = loop$array;
    let count = loop$count;
    let chunks = loop$chunks;
    let size$1 = size(array);
    let $ = size$1 <= count;
    if ($) {
      if (size$1 === 0) {
        return from_reverse_list(chunks);
      } else {
        return from_reverse_list(listPrepend(array, chunks));
      }
    } else {
      let $1 = split(array, count);
      let chunk;
      let rest$1;
      chunk = $1[0];
      rest$1 = $1[1];
      loop$array = rest$1;
      loop$count = count;
      loop$chunks = listPrepend(chunk, chunks);
    }
  }
}

/**
 * Returns an array of chunks containing `count` elements each.
 *
 * If the last chunk does not have count elements, it is instead a partial
 * chunk, with less than count elements.
 *
 * For any count less than 1 this function behaves as if it was set to 1.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function sized_chunk(array, count) {
  return sized_chunk_loop(array, $int.min(1, count), toList([]));
}

function split_n_loop(loop$array, loop$count, loop$rest, loop$chunks) {
  while (true) {
    let array = loop$array;
    let count = loop$count;
    let rest = loop$rest;
    let chunks = loop$chunks;
    let size$1 = size(array);
    let $ = size$1 <= count;
    if ($) {
      if (size$1 === 0) {
        return from_reverse_list(chunks);
      } else {
        return from_reverse_list(listPrepend(array, chunks));
      }
    } else {
      let _block;
      let $2 = rest > 0;
      if ($2) {
        _block = split(array, count + 1);
      } else {
        _block = split(array, count);
      }
      let $1 = _block;
      let chunk;
      let array$1;
      chunk = $1[0];
      array$1 = $1[1];
      loop$array = array$1;
      loop$count = count;
      loop$rest = rest - 1;
      loop$chunks = listPrepend(chunk, chunks);
    }
  }
}

/**
 * Returns an array distributing its elements evenly into `n` chunks.
 *
 * If there are less than `n` elements in the array, less chunks may be
 * returned.
 *
 * For any count less than 1 this function behaves as if it was set to 1.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function split_n(array, n_chunks) {
  return split_n_loop(
    array,
    divideInt(size(array), n_chunks),
    remainderInt(size(array), n_chunks),
    toList([]),
  );
}

/**
 * Return the array without the first element. If the array is empty,
 * `Error(Nil)` is returned.
 *
 * ```gleam
 * rest(from_list([1, 2, 3]))
 * // --> Ok(from_list([2, 3]))
 *
 * rest(new())
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function rest(array) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    return new Ok(drop_first(array, 1));
  }
}

/**
 * Return the array without the last element. If the array is empty,
 * `Error(Nil)` is returned.
 *
 * ```gleam
 * leading(from_list([1, 2, 3]))
 * // --> Ok(from_list([1, 2]))
 *
 * leading(new())
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function leading(array) {
  if (array instanceof Empty) {
    return $constants.error_nil;
  } else {
    return new Ok(drop_last(array, 1));
  }
}

/**
 * Extract a sub-slice from the array.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * let array = from_list([6, 7, 8, 9])
 *
 * slice_clamped(from: array, start: 1, size: 2)
 * // --> from_list([7, 8])
 *
 * slice_clamped(from: array, start: 2, size: 3)
 * // --> from_list([8, 9])
 *
 * slice_clamped(from: array, start: 5, size: 0)
 * // --> from_list([])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function slice_clamped(array, start, size) {
  let $ = split(array, start);
  let array$1;
  array$1 = $[1];
  let $1 = split(array$1, size);
  let array$2;
  array$2 = $1[0];
  return array$2;
}

/**
 * Extract a sub-slice from the array. If the start is not part of the
 * array or if the array does not contain enough elements, `Error(Nil)` is returned.
 *
 * This function runs in _O(log n)_ time.
 *
 * ```gleam
 * let array = from_list([6, 7, 8, 9])
 *
 * slice(from: array, start: 1, size: 2)
 * // --> Ok(from_list([7, 8]))
 *
 * slice(from: array, start: 2, size: 3)
 * // --> Error(Nil)
 *
 * slice(from: array, start: 5, size: 0)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function slice(array, start, size) {
  if (array instanceof Empty) {
    if (size === 0) {
      return new Ok(new Empty());
    } else {
      return $constants.error_nil;
    }
  } else {
    let root = array.root;
    let $ = (0 <= start) && ((start + size) <= $node.size(root));
    if ($) {
      return new Ok(slice_clamped(array, start, size));
    } else {
      return $constants.error_nil;
    }
  }
}

/**
 * Return a copy of the array, where each element is replaced by the result
 * of a function.
 *
 * ```gleam
 * map(from_list([6, 7, 8]), fn(x) { x * 2 })
 * // --> from_list([12, 14, 16])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function map(array, fun) {
  if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    return new Array(shift, $node.map(root, fun));
  }
}

/**
 * Return a copy of the array, where each element is replaced by the result
 * of applying a function to the index and the element at that index.
 *
 * ```gleam
 * index_map(from_list([6, 7, 8]), fn(x, i) { #(i, x) })
 * // --> from_list([#(0, 6), #(1, 7), #(2, 8)])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function index_map(array, fun) {
  if (array instanceof Empty) {
    return array;
  } else {
    let shift = array.shift;
    let root = array.root;
    return new Array(shift, $node.index_map(shift, 0, root, fun));
  }
}

/**
 * Return a copy of the array, where each element is replaced by the `Ok(_)`
 * result of applying a function to each element.
 *
 * If the fuction returns `Error(_)` for any of the elements, that error is
 * immediately returned instead.
 *
 * ```gleam
 * try_map(from_list([[1], [2, 3]]), list.first)
 * // --> Ok(from_list([1, 2]))
 *
 * try_map(from_list([[1], [], [2, 3]]), list.first)
 * // --> Error(Nil)
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_map(array, fun) {
  if (array instanceof Empty) {
    return new Ok(new Empty());
  } else {
    let shift = array.shift;
    let root = array.root;
    let $ = $node.try_map(root, fun);
    if ($ instanceof Ok) {
      let root$1 = $[0];
      return new Ok(new Array(shift, root$1));
    } else {
      return $;
    }
  }
}

/**
 * Combine 2 arrays into a single array using the given function.
 *
 * If one array is longer than the other, the extra elements are dropped from
 * the end.
 *
 * ```gleam
 * map2(from_list([1, 2, 3]), from_list([4, 5, 6]), int.add)
 * // --> from_list([5, 7, 9])
 *
 * map2(from_list([1, 2]), from_list(["a", "b", "c"]), fn(a, b) { #(a, b) })
 * // --> from_list([#(1, "a"), #(2, "b")])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function map2(a, b, fun) {
  let _pipe = $yielder.map2(to_yielder(a), to_yielder(b), fun);
  return from_yielder(_pipe);
}

/**
 * Combine 2 arrays into a single array of 2-element tuples.
 *
 * If one array is longer than the other, the extra elements are dropped from
 * the end.
 *
 * ```gleam
 * zip(from_list([1, 2, 3]), from_list(["a", "b", "c"]))
 * // --> from_list([#(1, "a"), #(2, "b"), #(3, "c")])
 *
 * zip(from_list([]), from_list(["a", "b", "c"]))
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function zip(a, b) {
  return map2(a, b, (a, b) => { return [a, b]; });
}

/**
 * Build up a new value by looping through each of the elements from the start
 * to the end.
 *
 * ```gleam
 * fold(from_list([6, 7, 8]), from: 0, with: int.add)
 * // --> 21
 *
 * fold(from_list([6, 7, 8]), from: [], with: list.prepend)
 * // --> [8, 7, 6]
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function fold(array, state, fun) {
  if (array instanceof Empty) {
    return state;
  } else {
    let root = array.root;
    return $node.fold(root, state, fun);
  }
}

/**
 * Convert a string array to a single string by joining the items together
 * using the given separator.
 *
 * ```gleam
 * from_list(["trans", "rights", "are", "human", "rights"])
 * |> join(with: " ")
 *  // --> "trans rights are human rights"
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function join(strings, separator) {
  let $ = get(strings, 0);
  if ($ instanceof Ok) {
    let first$1 = $[0];
    return fold(
      drop_first(strings, 1),
      first$1,
      (result, string) => { return (result + separator) + string; },
    );
  } else {
    return "";
  }
}

/**
 * Concatenate many arrays, joining them up to form a single array.
 *
 * This function runs in _O(n)_ time, only depending on the number of arrays.
 *
 * ```gleam
 * flatten(from_list([from_list([1]), new(), from_list([2, 3])]))
 * // --> from_list([1, 2, 3])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function flatten(arrays) {
  return fold(arrays, new Empty(), concat);
}

/**
 * Map every element in the array to a new array, and then flatten them.
 *
 * ```gleam
 * flat_map(from_list([2, 4, 6]), fn(x) { from_list([x, x + 1]) })
 * // --> from_list([2, 3, 4, 5, 6, 7])
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function flat_map(array, fun) {
  return fold(
    array,
    new Empty(),
    (result, item) => { return concat(result, fun(item)); },
  );
}

/**
 * Build a new array containing only the elements for which the given function
 * returns `True`.
 *
 * ```gleam
 * filter(from_list([1, 2, 3, 4]), int.is_even)
 * // --> from_list([2, 4])
 *
 * filter(from_list([1, 2, 3, 4]), fn(x) { x > 6 })
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function filter(items, predicate) {
  let result = $builder.build(
    fold(
      items,
      $builder.new$(),
      (builder, item) => {
        let $ = predicate(item);
        if ($) {
          return $builder.push(builder, item);
        } else {
          return builder;
        }
      },
    ),
  );
  if (result instanceof Ok) {
    let shift = result[0][0];
    let nodes = result[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Build a new array containing only the values for which the given function
 * returns `Ok(_)`.
 *
 * ```gleam
 * filter_map(from_list([[], [1], [2, 3]]), list.first)
 * // --> from_list([1, 2])
 *
 * filter_map(from_list([1, 2, 3]), Error)
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function filter_map(items, fun) {
  let result = $builder.build(
    fold(
      items,
      $builder.new$(),
      (builder, item) => {
        let $ = fun(item);
        if ($ instanceof Ok) {
          let new_item = $[0];
          return $builder.push(builder, new_item);
        } else {
          return builder;
        }
      },
    ),
  );
  if (result instanceof Ok) {
    let shift = result[0][0];
    let nodes = result[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Loop through the elements from the start to the end, calling a function
 * and discarding the result.
 *
 * Useful for performing some side-effects for every element.
 *
 * ```gleam
 * use item <- each(from_list([1, 2, 3]))
 * io.println(int.to_string(item))
 * // 1
 * // 2
 * // 3
 * // --> Nil
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function each(array, something) {
  return fold(
    array,
    undefined,
    (_use0, item) => {
      
      something(item);
      return undefined;
    },
  );
}

/**
 * Like `fold`, but also passes the index of the current element.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function index_fold(array, state, fun) {
  if (array instanceof Empty) {
    return state;
  } else {
    let shift = array.shift;
    let root = array.root;
    return $node.index_fold(shift, 0, root, state, fun);
  }
}

/**
 * Build up a new value by looping in reverse from the end to the start through
 * the array.
 *
 * ```gleam
 * fold_right(from_list([6, 7, 8]), from: 0, with: int.add)
 * // --> 21
 *
 * fold_right(from_list([6, 7, 8]), from: [], with: list.prepend)
 * // --> [6, 7, 8]
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function fold_right(array, state, fun) {
  if (array instanceof Empty) {
    return state;
  } else {
    let root = array.root;
    return $node.fold_right(root, state, fun);
  }
}

/**
 * Convert an array to a standard Gleam list.
 *
 * ```gleam
 * to_list(initialise(5, fn(x) { x + 1 }))
 * // --> [1, 2, 3, 4, 5]
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function to_list(array) {
  return fold_right(array, toList([]), $list.prepend);
}

/**
 * Create a new array containing the same elements, but in the opposite order.
 *
 * ```gleam
 * reverse(from_list([6, 7, 8]))
 * // --> from_list([8, 7, 6])
 *
 * reverse(from_list([1]))
 * // --> from_list([1])
 *
 * reverse(new())
 * // --> new()
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function reverse(items) {
  let $ = (() => {
    let _pipe = items;
    let _pipe$1 = fold_right(_pipe, $builder.new$(), $builder.push);
    return $builder.build(_pipe$1);
  })();
  if ($ instanceof Ok) {
    let shift = $[0][0];
    let nodes = $[0][1];
    return array(shift, nodes);
  } else {
    return new Empty();
  }
}

/**
 * Loop through the elements in reverse order from the end to the start,
 * calling a function on each element and discarding the result.
 *
 * Useful for performing some side-effects for every element.
 *
 * ```gleam
 * use item <- each(from_list([1, 2, 3]))
 * io.println(int.to_string(item))
 * // 3
 * // 2
 * // 1
 * // --> Nil
 * ```
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function each_right(array, something) {
  return fold_right(
    array,
    undefined,
    (_use0, item) => {
      
      something(item);
      return undefined;
    },
  );
}

/**
 * Like `fold`, but pass the current index to the accumulator function.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function index_fold_right(array, state, fun) {
  if (array instanceof Empty) {
    return state;
  } else {
    let shift = array.shift;
    let root = array.root;
    return $node.index_fold_right(shift, 0, root, state, fun);
  }
}

/**
 * A variant of `fold` that builds up a new value using a function that can
 * fail.
 *
 * If the function returns `Error(_)`, iteration is stopped and the error is
 * returned immediately. Otherwise, the final built-up value is returned.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_fold(array, state, fun) {
  if (array instanceof Empty) {
    return new Ok(state);
  } else {
    let root = array.root;
    return $node.try_fold(root, state, fun);
  }
}

/**
 * Loop through the elements from the start to the end, calling a
 * result-returning function for all of them. As soon as the function returns
 * `Error(_)`, iteration is stopped and the error is returned.
 *
 * <div style="text-align: right;">
 *     <a href="#">
 *         <small>Back to top ↑</small>
 *     </a>
 * </div>
 */
export function try_each(array, something) {
  return try_fold(
    array,
    undefined,
    (_use0, item) => {
      
      let $ = something(item);
      if ($ instanceof Ok) {
        return new Ok(undefined);
      } else {
        return $;
      }
    },
  );
}
