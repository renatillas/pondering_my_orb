//// <style>
////   small {
////     font-size: 0.7em;
////     opacity: 0.75;
////   }
////   h4 {
////     margin-bottom: 0;
////     + p {
////       margin-top: 0;
////     }
////   }
//// </style>
//// <script>
//// (callback => document.readyState !== 'loading' ? callback() : document.addEventListener('DOMContentLoaded', callback, { once: true }))(() => {
////   const list = document.querySelector('.sidebar > ul:last-of-type')
////   const sortedLists = document.createDocumentFragment()
////   const sortedMembers = document.createDocumentFragment()
////
////   for (const header of document.querySelectorAll('main > h4')) {
////     sortedLists.append((() => {
////       const node = document.createElement('h3')
////       node.append(header.textContent)
////       return node
////     })())
////     sortedMembers.append((() => {
////       const node = document.createElement('h2')
////       node.append(header.textContent)
////       return node
////     })())
////
////     const sortedList = document.createElement('ul')
////     sortedLists.append(sortedList)
////
////     for (const anchor of header.nextElementSibling.querySelectorAll('a')) {
////       const href = anchor.getAttribute('href')
////       const member = document.querySelector(`.member:has(h2 > a[href="${href}"])`)
////       const sidebar = list.querySelector(`li:has(a[href="${href}"])`)
////       sortedList.append(sidebar)
////       sortedMembers.append(member)
////     }
////   }
////
////   document.querySelector('.sidebar').insertBefore(sortedLists, list)
////   document.querySelector('.module-members:has(#module-values)').insertBefore(sortedMembers, document.querySelector('#module-values').nextSibling)
//// })
//// </script>
////
//// `iv` is an immutable array structure written in Gleam. You can use it
//// like you would use an array in other programming languages and expect
//// comparable or better runtime characteristics.
////
//// **Tip:** Hover the links for short summaries!
////
//// #### Create & Convert
//// [new](#new "Create an empty array"),
//// [wrap](#wrap "A single element"),
//// [repeat](#repeat "Repeat a single element"),
//// [from_list](#from_list "Convert a list to an array"),
//// [from_reverse_list](#from_reverse_list "Convert a reversed list to an array"),
//// [from_yielder](#from_yielder "Consume any yielder to build an array"),
//// [initialise](#initialise "Use a constructor function for every element") \
//// [to_list](#to_list "Convert to a list"),
//// [to_yielder](#to_yielder "Create a yielder iterating through the array"),
//// [join](#join "Convert a string array to a string")
////
//// #### Query
//// [is_empty](#is_empty "Is the array empty?"),
//// [size](#size "Number of elements"),
//// [equal](#equal "Are 2 arrays equal?"),
//// [any](#any "Does any element have a property?"),
//// [all](#all "Do all elements have a property?") \
//// [contains](#contains "Does the array contain an element?"),
//// [index_of](#index_of "Get the index of an element"),
//// [last_index_of](#last_index_of "Get index of an element from the end"),
//// [get](#get "Get the element at an index"),
//// [get_or_default](#get_or_default "Get the element at an index or a fallback value"),
//// [at](#at "Get the element at an index"),
//// [find](#find "Find the first element with a property"),
//// [find_index](#find_index "Find the index of the first element with a property"),
//// [find_last_index](#find_last_index "Find the index of the last element with a property"),
//// [find_map](#find_map "Find the first Ok(_)")
////
//// #### Manipulate
////
//// [set](#set "Set an element"),
//// [try_set](#try_set "Set an element if the index exists"),
//// [update](#update "Update an element"),
//// [try_update](#try_update "Update an element if the index exists")
//// [insert](#insert "Insert an element"),
//// [insert_clamped](#insert_clamped "Insert, prepend, or append an element"),
//// [insert_list](#insert_list "Insert many elements"),
//// [insert_list_clamped](#insert_list_clamped "Insert, prepend, or append many elements"),
//// [delete](#delete "Delete an element"),
//// [try_delete](#try_delete "Delete an element, if it exists") \
//// [swap_delete](#swap_delete "Swap an element with the last, then delete the last element"),
//// [try_swap_delete](#try_swap_delete "Swan an element with the last, then delete the last element") \
//// [append](#append "Add an element to the end"),
//// [append_list](#append_list "Add many elements to the end"),
//// [append_reverse_list](#append_reverse_list "Add many elements to the end, in reverse order"),
//// [prepend](#prepend "Add an element at the start"),
//// [prepend_list](#prepend_list "Add many elements at the start"),
//// [prepend_reverse_list](#prepend_reverse_list "Add many elements at the start, in reverse order"),
//// [replace](#replace "Replace a range of elements"),
//// [splice](#splice "Replace a range of elements using a function")
////
//// #### Concatenate & Split
//// [concat](#concat "Concatenate two arrays"),
//// [concat_list](#concat_list "Concatenate many arrays"),
//// [flatten](#flatten "Concatenate nested arrays"),
//// [split](#split "Split an array at an index"),
//// [split_n](#split_n "N-way split")
//// [slice](#slice "Get a slice of the array"),
//// [slice_clamped](#slice_clamped "Get a slice of the array"),
//// [drop_first](#drop_first "Remove the first elements"),
//// [drop_last](#drop_last "Remove the last elements"),
//// [take_first](#take_first "Take the first elements"),
//// [take_last](#take_last "Take the last elements"),
//// [sized_chunk](#sized_chunk "Split an array into chunks")
////
//// #### Transform
//// [reverse](#reverse "Reverse the order"),
//// [map](#map "Transform every element"),
//// [try_map](#try_map "Transform every element using a fallible function"),
//// [index_map](#index_map "Transform every element using its index"),
//// [flat_map](#flat_map "Map every element to anoher array"),
//// [filter](#filter "Filter elements based on a property"),
//// [filter_map](#filter_map "Collect all Ok values"),
//// [zip](#zip "Combine elements of 2 arrays"),
//// [map2](#map2 "Combine 2 arrays usng a function")
////
//// #### Looping
//// [each](#each "Loop start to end"),
//// [try_each](#try_each "Loop until error"),
//// [each_right](#each_right "Loop end to start"),
//// [fold](#fold "Loop start to end, with state"),
//// [index_fold](#index_fold "Loop start to end, with index and state"),
//// [try_fold](#try_fold "Loop until error, with state"),
//// [fold_right](#fold_right "Loop end to start, with state"),
//// [index_fold_right](#index_fold_right "Loop end to start, with index and state")

import gleam/int
import gleam/list
import gleam/yielder.{type Yielder}
import iv/internal/builder
import iv/internal/constants
import iv/internal/iterator
import iv/internal/node.{type Node, branch_bits}
import iv/internal/vector.{type Vector}

// An implementation of RRB-Vectors, in Gleam!
//
// Sources:
//
// L'orange, J. N. (2014). Improving RRB-Tree Performance through Transience
// Stucki, N., Rompf, T., Ureche, V., & Bagwell, P. (2015). RRB Vector: a practical general purpose immutable sequence. In Proceedings of the 20th ACM SIGPLAN International Conference on Functional Programming (pp. 342-354).
// Bagwell, P., Rompf, T. (2011). RRB-Trees: efficient immutable vectors.
// Horne-Khan, P. (2024). Relaxed Radix Balanced Trees. Available: https://peter.horne-khan.com/relaxed-radix-node.balanced-trees/
// konsumlamm (2021). rrb-vector: Efficient RRB-Vectors. Available: https://github.com/konsumlamm/rrb-vector/tree/master
// Hansen, R. H. (2017). Elm array exploration. Available: https://github.com/robinheghan/elm-array-exploration

/// A fast immutable array.
pub opaque type Array(item) {
  Empty
  Array(shift: Int, root: Node(item))
}

fn array(shift shift: Int, children nodes: Vector(Node(item))) {
  case vector.length(nodes) {
    0 -> Empty
    1 -> Array(shift:, root: vector.get(1, nodes))
    _ -> {
      let shift = shift + branch_bits
      Array(shift:, root: node.branch(shift, nodes))
    }
  }
}

// -- CONSTRUCTING AND DECONSTRUCTING ARRAYS -----------------------------------

/// Returns a new empty array.
///
/// ```gleam
/// new()
/// // --> from_list([])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn new() {
  Empty
}

/// Returns the given item wrapped in a list.
///
/// ```gleam
/// wrap(42)
/// // --> from_list([42])
///
/// wrap(from_list([1, 2, 3]))
/// // --> from_list([from_list([1, 2, 3])])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn wrap(of item: item) -> Array(item) {
  Array(shift: 0, root: node.Leaf(vector.singleton(item)))
}

/// Converts the given list to an array.
///
/// ```gleam
/// length(from_list([1, 2, 3]))
/// // --> 3
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn from_list(list: List(item)) -> Array(item) {
  case
    list
    |> list.fold(builder.new(), builder.push)
    |> builder.build
  {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Convert the given list to an array that contains all items in the reverse
/// order from the original list.
///
/// Equivalent to `iv.from_list(list.reverse(items))`.
///
/// This is useful as the last step in a tail-recursive algorithm building up a
/// list as an intermediary. Instead of calling `list.reverse` and then
/// converting the final list to an array, it's faster to use this function
/// instead!
///
/// ```gleam
/// from_reverse_list([1, 2, 3])
/// // --> from_list([3, 2, 1])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn from_reverse_list(list: List(item)) -> Array(item) {
  case
    list
    |> list.fold(builder.reverse(), builder.push)
    |> builder.build
  {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Consume the given yielder, collecting all elements into a new array.
///
/// ```gleam
/// from_yielder(
///   yielder.range(1, 3)
///   |> yielder.cycle()
///   |> yielder.take(10)
/// )
/// // --> from_list([1, 2, 3, 1, 2, 3, 1, 2, 3, 1])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn from_yielder(source: Yielder(item)) -> Array(item) {
  case
    source
    |> yielder.fold(builder.new(), builder.push)
    |> builder.build
  {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Convert an array to a standard Gleam list.
///
/// ```gleam
/// to_list(initialise(5, fn(x) { x + 1 }))
/// // --> [1, 2, 3, 4, 5]
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn to_list(array: Array(item)) -> List(item) {
  fold_right(array, [], list.prepend)
}

/// Return a yielder iterating through an array.
///
/// Yielders are more efficient then repeatetly querying the index, but slower
/// than using more specialised functions like [each](#each) or [fold](#fold).
/// Only use this if you need to pause or iterate through many arrays at once.
///
/// ```gleam
/// to_yielder(from_list([1, 2, 3]))
/// |> yielder.cycle
/// |> yielder.take(10)
/// |> yielder.to_list
/// // --> [1, 2, 3, 1, 2, 3, 1, 2, 3, 1]
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn to_yielder(array: Array(item)) -> Yielder(item) {
  case array {
    Empty -> yielder.empty()
    Array(root:, ..) -> iterator.new(root)
  }
}

/// Convert a string array to a single string by joining the items together
/// using the given separator.
///
/// ```gleam
/// from_list(["trans", "rights", "are", "human", "rights"])
/// |> join(with: " ")
///  // --> "trans rights are human rights"
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn join(strings: Array(String), with separator: String) -> String {
  case get(strings, 0) {
    Error(_) -> ""
    Ok(first) -> {
      use result, string <- fold(drop_first(strings, 1), first)
      result <> separator <> string
    }
  }
}

/// Build an array by repeating the given element a number of times.
///
/// ```gleam
/// repeat("hi", times: 3)
/// // --> from_list(["hi", "hi", "hi"])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn repeat(item item: item, times times: Int) -> Array(item) {
  initialise(times, fn(_) { item })
}

/// Creates a list of ints ranging from a given start and finish.
///
/// ```gleam
/// range(1, 3)
/// // --> from_list([1, 2, 3])
///
/// range(10, 1)
/// // --> from_list([10, 9, 8, 7, 6, 5, 4, 3, 2, 1])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use initialise instead.")
pub fn range(from start: Int, to stop: Int) -> Array(Int) {
  case start <= stop {
    True -> initialise(stop - start + 1, fn(x) { x + start })
    False -> initialise(start - stop + 1, fn(x) { start - x })
  }
}

/// Create a list using a constructor function for each element.
/// The function receives the current index as an input.
///
/// ```gleam
/// initialise(5, fn(i) { i * 2 })
/// // --> from_list([0, 2, 4, 6, 8])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn initialise(length length: Int, with fun: fn(Int) -> item) -> Array(item) {
  case initialise_loop(0, length, builder.new(), fun) {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

fn initialise_loop(idx, length, builder, fun) {
  case idx < length {
    True ->
      initialise_loop(idx + 1, length, builder.push(builder, fun(idx)), fun)
    False -> builder.build(builder)
  }
}

// -- QUERY --------------------------------------------------------------------

/// Check whether or not an array is empty.
///
/// ```gleam
/// is_empty(from_list([]))
///  // --> True
///
/// is_empty(from_list([1, 2, 3]))
/// // --> False
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn is_empty(array: Array(item)) -> Bool {
  case array {
    Empty -> True
    Array(..) -> False
  }
}

/// Returns the number of items in the array.
///
/// ```gleam
/// size(from_list([]))
/// // --> 0
///
/// size(from_list(["hello", "joe"]))
/// // --> 2
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn size(array: Array(item)) -> Int {
  case array {
    Empty -> 0
    Array(root:, ..) -> node.size(root)
  }
}

/// Returns the number of items in the array.
///
/// ```gleam
/// length(from_list([]))
/// // --> 0
///
/// length(from_list(["hello", "joe"]))
/// // --> 2
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use size instead.")
pub fn length(array: Array(item)) {
  size(array)
}

/// Checks whether or not two arrays are equal. Arrays are considered to be
/// equal if they have the same length, and their elements are pairwise equal.
///
/// **Important:** Always use this function instead of the `==` operator! \
/// Arrays containing the same elements can have different runtime representations.
///
/// ```gleam
/// equal(from_list([1, 2, 3]), initialise(3, fn(x) { x + 1 }))
/// // --> True
///
/// equal(from_list([1, 2, 3]), from_list([1]))
/// // --> False
///
/// equal(from_list([1, 2, 3]), from_list([1, 2, 4]))
/// // --> False
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn equal(a: Array(item), b: Array(item)) -> Bool {
  case size(a) == size(b) {
    True -> {
      // I hereby vow that I tried it in other ways and also just arrived at the
      // yielder pattern.
      yielder.map2(to_yielder(a), to_yielder(b), fn(a, b) { a == b })
      |> yielder.all(fn(a) { a })
    }
    False -> False
  }
}

/// Check if a function returns `True` for at least one of the elements
/// in the array.
///
/// ```gleam
/// any(new(), int.is_even)
/// // --> False
///
/// any(from_list([1, 3, 5]), int.is_even)
/// // --> False
///
/// any(from_list([1, 2, 3]), int.is_even)
/// // --> True
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn any(
  in array: Array(item),
  satisfying predicate: fn(item) -> Bool,
) -> Bool {
  case find(array, predicate) {
    Ok(_) -> True
    Error(_) -> False
  }
}

/// Check if a fuction returns `True` for every element in the array.
///
/// ```gleam
/// all(new(), int.is_even)
///  // --> True
///
/// all(from_list([1, 2, 3]), int.is_even)
/// // --> False
///
/// all(from_list([2, 4, 6]), int.is_even)
/// // --> True
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn all(
  in array: Array(item),
  satisfying predicate: fn(item) -> Bool,
) -> Bool {
  !any(array, fn(item) { !predicate(item) })
}

/// Linearly search through the array to check if it contains an item.
///
/// ```gleam
/// contains(in: new(), any: 0)
/// // --> False
///
/// contains(in: from_list([1, 2, 3]), any: 2)
/// // --> True
///
/// contains(in: from_list([1, 2, 3]), any: 5)
/// // --> False
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn contains(in array: Array(item), any item: item) -> Bool {
  any(array, fn(other) { other == item })
}

/// Get the first element from the start of the array, if there is one.
///
/// ```gleam
/// first(new())
/// // --> Error(Nil)
///
/// first(from_list([1, 2, 3]))
/// // --> Ok(1)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use get(0) instead.")
pub fn first(from array: Array(item)) -> Result(item, Nil) {
  get(array, 0)
}

/// Get the last element in the array, if there is one.
///
/// ```gleam
/// last(new())
/// // --> Error(Nil)
///
/// last(from_list([1]))
/// // --> Ok(1)
///
/// last(from_list([1, 2, 3]))
/// // --> Ok(3)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use at(-1) instead.")
pub fn last(from array: Array(item)) -> Result(item, Nil) {
  get(array, size(array) - 1)
}

/// Get the element at a specific index.
///
/// Arrays are 0-based, so the first element is at index `0`, the second is at
/// index `1`, the third is at index `2`, and so forth, up to `length - 1`.
///
/// ```gleam
/// let array = from_list(["trans", "rights", "are", "human", "rights"])
///
/// get(from: array, at: 1)
/// // --> Ok("rights")
///
/// get(from: array, at: 3)
/// // --> Ok("human")
///
/// get(from: array, at: -1)
/// // --> Error(Nil)
///
/// get(from: array, at: 5)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn get(from array: Array(item), at index: Int) -> Result(item, Nil) {
  case array {
    Array(shift:, root:) ->
      case 0 <= index && index < node.size(root) {
        True -> Ok(node.get(root, shift, index))
        False -> constants.error_nil
      }
    Empty -> constants.error_nil
  }
}

/// Get the element at a specific index. If the index is negative, get the
/// nth-last element instead.
///
/// ```gleam
/// let array = from_list(["trans", "rights", "are", "human", "rights"])
///
/// at(from: array, at: 1)
/// // --> Ok("rights")
///
/// at(from: array, at: 3)
/// // --> Ok("human")
///
/// at(from: array, at: -1)
/// // --> Ok("rights")
///
/// at(from: array, at: 5)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn at(from array: Array(item), at index: Int) -> Result(item, Nil) {
  case index >= 0 {
    True -> get(array, index)
    False -> get(array, size(array) + index)
  }
}

/// Get the element at a specific index, or a default value if the index is out
/// of range.
///
/// Arrays are 0-based, so the first element is at index `0`, the second is at
/// index `1`, the third is at index `2`, and so forth, up to `length - 1`.
///
/// ```gleam
/// let array = from_list(["trans", "rights", "are", "human", "rights"])
///
/// get_or_default(from: array, at: 1, or: "")
/// // --> "rights"
///
/// get_or_default(from: array, at: 3, or: "")
/// // --> "human"
///
/// get_or_default(from: array, at: -1, or: "")
/// // --> ""
///
/// get_or_default(from: array, at: 5, or: "")
/// // --> ""
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn get_or_default(
  from array: Array(item),
  at index: Int,
  or default: item,
) -> item {
  case array {
    Array(shift:, root:) ->
      case 0 <= index && index < node.size(root) {
        True -> node.get(root, shift, index)
        False -> default
      }
    Empty -> default
  }
}

/// Find the first element from the start  of the array for which the given
/// function returns `True`, and return it.
///
/// ```gleam
/// find(from_list([1, 2, 3, 4]), fn(x) { x > 2 })
/// // --> Ok(3)
///
/// find(from_list([1, 2, 3, 4]), fn(x) { x > 4 })
/// // --> Error(Nil)
///
/// find(new(), fn(_) { True })
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn find(
  in array: Array(item),
  one_that is_desired: fn(item) -> Bool,
) -> Result(item, Nil) {
  use item <- find_map(array)
  case is_desired(item) {
    True -> Ok(item)
    False -> constants.error_nil
  }
}

/// Find the first element for which the given function returns `Ok(value)`,
/// and return the wrapped value.
///
/// ```gleam
/// find_map(from_list([[], [2], [3]]), list.first)
/// // --> Ok(2)
///
/// find_map(from_list([[], []]), list.first)
/// // --> Error(Nil)
///
/// find_map(new(), first)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn find_map(
  in array: Array(a),
  one_that is_desired: fn(a) -> Result(b, Nil),
) -> Result(b, Nil) {
  case array {
    Empty -> constants.error_nil
    Array(root:, ..) -> node.find_map(root, is_desired)
  }
}

/// Return the index of the first occurrence of the given element in the array,
/// or `Error(Nil)` if the array doesn't contain the element.
///
/// ```gleam
/// index_of(from_list([4, 5, 6, 5]), of: 5)
/// // --> Ok(1)
///
/// index_of(from_list([4, 5, 6, 5]), of: 1)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn index_of(in array: Array(item), of item: item) -> Result(Int, Nil) {
  find_index(array, fn(other) { other == item })
}

/// Return the index of the first element in the array for which the given
/// function returns `True`, or `Error(Nil)` if no such element can be found.
///
/// ```gleam
/// find_index(from_list([4, 5, 6, 5]), fn(x) { x > 5 })
/// // --> Ok(2)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn find_index(
  in array: Array(item),
  one_that is_desired: fn(item) -> Bool,
) -> Result(Int, Nil) {
  case array {
    Empty -> constants.error_nil
    Array(root:, shift:) -> node.find_index(shift, 0, root, is_desired)
  }
}

/// Return the index of the last occurrence of the given element in the array,
/// or `Error(Nil)` if the array doesn't contain the element.
///
/// ```gleam
/// last_index_of(from_list([4, 5, 6, 5]), of: 5)
/// // --> Ok(3)
///
/// last_index_of(from_list([4, 5, 6, 5]), of: 1)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn last_index_of(in array: Array(item), of item: item) -> Result(Int, Nil) {
  find_last_index(array, fn(other) { other == item })
}

/// Return the index of the last element in the array for which the given
/// function returns `True`, or `Error(Nil)` if no such element can be found.
///
/// ```gleam
/// find_last_index(from_list([4, 5, 6, 7]), fn(x) { x > 5 })
/// // --> Ok(3)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn find_last_index(
  in array: Array(item),
  one_that is_desired: fn(item) -> Bool,
) -> Result(Int, Nil) {
  case array {
    Empty -> constants.error_nil
    Array(root:, shift:) -> node.find_last_index(shift, 0, root, is_desired)
  }
}

// -- MANIPULATE ---------------------------------------------------------------

/// Store a new value at a given index and return the new array, or `Error(Nil)`
/// if the index cannot be found in the array.
///
/// ```gleam
/// from_list([1, 2, 3]) |> set(at: 1, to: 50)
/// // --> Ok(from_list([1, 50, 3]))
///
/// from_list([1, 2, 3]) |> set(at: -1, to: 50)
/// // --> Error(Nil)
///
/// from_list([]) |> set(at: 0, to: 1)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn set(
  in array: Array(item),
  at index: Int,
  to item: item,
) -> Result(Array(item), Nil) {
  update(array, index, fn(_) { item })
}

/// Store a new value at a given index and return the new array, or return the
/// given array unchanged if the index cannot be found.
///
/// ```gleam
/// from_list([1, 2, 3]) |> try_set(at: 1, to: 50)
/// // --> from_list([1, 50, 3])
///
/// from_list([1, 2, 3]) |> try_set(at: -1, to: 50)
/// // --> from_list([1, 2, 3])
///
/// from_list([]) |> try_set(at: 0, to: 1)
/// // --> from_list([])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_set(
  in array: Array(item),
  at index: Int,
  to item: item,
) -> Array(item) {
  try_update(array, index, fn(_) { item })
}

/// Update the element at a given index and return a new array, or return
/// `Error(Nil)` if the index cannot be found in the array.
///
/// This is slightly more efficient than `get`-ing and then `set`-ing the element.
///
/// ```gleam
/// from_list([1, 2, 3]) |> update(at: 1, with: fn(x) { x * 2 })
/// // --> Ok(from_list([1, 4, 3]))
///
/// from_list([1, 2, 3]) |> update(at: -1, with: fn(x) { x + 1 })
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn update(
  in array: Array(item),
  at index: Int,
  with fun: fn(item) -> item,
) -> Result(Array(item), Nil) {
  case array {
    Array(root:, shift:) ->
      case 0 <= index && index < node.size(root) {
        True -> Ok(Array(shift:, root: node.update(shift, root, index, fun)))
        False -> constants.error_nil
      }
    Empty -> constants.error_nil
  }
}

/// Update the element at a given index and return a new array, or return the
/// given array unchanged if the index cannot be found in the array.
///
/// This is more efficient than `get`-ing and then `try_set`-ing the element.
///
/// ```gleam
/// from_list([1, 2, 3]) |> try_update(at: 1, with: fn(x) { x * 2 })
/// // --> from_list([1, 4, 3])
///
/// from_list([1, 2, 3]) |> try_update(at: -1, with: fn(x) { x + 1 })
/// // --> from_list([1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_update(
  in array: Array(item),
  at index: Int,
  with fun: fn(item) -> item,
) -> Array(item) {
  case array {
    Array(root:, shift:) ->
      case 0 <= index && index < node.size(root) {
        True -> Array(shift:, root: node.update(shift, root, index, fun))
        False -> array
      }
    Empty -> array
  }
}

/// Add an element to the end of an array.
///
/// ```gleam
/// from_list(["hello"]) |> append("joe")
/// // --> from_list(["hello", "joe"])
///
/// from_list([1, 2, 3]) |> append(4) |> append(0)
/// // --> from_list([1, 2, 3, 4, 0])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn append(to array: Array(item), this item: item) -> Array(item) {
  direct_concat(array, wrap(item))
}

/// Add all elements in a list to the end of the array.
///
/// This more efficient than `append`-ing all elements individually.
///
/// This function runs in _O(n)_ time, only depending on the size of the appended list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> append_list([4, 0])
/// // --> from_list([1, 2, 3, 4, 0])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn append_list(
  to array: Array(item),
  these items: List(item),
) -> Array(item) {
  direct_concat(array, from_list(items))
}

/// Add all elements in a list to the end of the array, in reverse order.
///
/// This is more efficient than reversing the list first and then `append`-ing
/// all the elements.
///
/// This is useful in tail-recursive algorithms to first build-up a intermediary
/// list instead of appending all elements immediately.
///
/// This function runs in _O(n)_ time, only depending on the size of the appended list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> append_reverse_list([4, 0])
/// // --> from_list([1, 2, 3, 0, 4])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn append_reverse_list(
  to array: Array(item),
  these items: List(item),
) -> Array(item) {
  direct_concat(array, from_reverse_list(items))
}

/// Add an element to the start of the array, making it the first element.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list(["joe"]) |> prepend("hello")
/// // --> from_list(["hello", "joe"])
///
/// from_list([1, 2, 3]) |> prepend(4) |> prepend(0)
/// // --> from_list([0, 4, 1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn prepend(to array: Array(item), this item: item) -> Array(item) {
  direct_concat(wrap(item), array)
}

/// Add many elements to the start of the array, in the same order they appear
/// in the list.
///
/// This is more efficient than inserting all elements individually.
///
/// This function runs in _O(n)_ time, only depending on the size of the prepended list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> prepend_list([4, 5, 6])
/// // --> from_list([4, 5, 6, 1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn prepend_list(
  to array: Array(item),
  these items: List(item),
) -> Array(item) {
  direct_concat(from_list(items), array)
}

/// Add many elements to the start of the array, in the reverse order they appear
/// in the list.
///
/// This is more efficient than reversing the list first and then prepending it.
///
/// This is useful in tail-recursive algorithms to first build-up a intermediary
/// list instead of prepending all elements immediately.
///
/// This function runs in _O(n)_ time, only depending on the size of the prepended list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> prepend_list([4, 5, 6])
/// // --> from_list([6, 5, 4, 1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn prepend_reverse_list(
  to array: Array(item),
  these items: List(item),
) -> Array(item) {
  direct_concat(from_reverse_list(items), array)
}

/// Insert an element at an index into the array, moving all existing elements.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// new() |> insert(at: 0, this: "hi")
/// // --> Ok(from_list(["hi"]))
///
/// from_list([1, 2, 3]) |> insert(at: 1, this: 50)
/// // --> Ok(from_list([1, 50, 2, 3]))
///
/// from_list([1, 2, 3]) |> insert(at: 3, this: 4)
/// // --> Ok(from_list([1, 2, 3, 4]))
///
/// from_list([1, 2, 3]) |> insert(at: 5, this: 100)
/// // --> Error(Nil)
///
/// from_list([1, 2, 3]) |> insert(at: -1, this: 0)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn insert(
  into array: Array(item),
  at index: Int,
  this item: item,
) -> Result(Array(item), Nil) {
  case size(array) {
    len if 0 <= index && index <= len -> {
      let #(before, after) = split(array, index)
      Ok(concat(direct_concat(before, wrap(item)), after))
    }
    _ -> constants.error_nil
  }
}

/// Insert an element at an index into the array, moving all existing elements.
/// If the index is less than `0` prepend, and if it's greater than the number
/// of elements in the array append instead.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// new() |> insert_clamped(at: 0, this: "hi")
/// // --> from_list(["hi"])
///
/// from_list([1, 2, 3]) |> insert_clamped(at: 1, this: 50)
/// // --> from_list([1, 50, 2, 3])
///
/// from_list([1, 2, 3]) |> insert_clamped(at: 3, this: 4)
/// // --> from_list([1, 2, 3, 4])
///
/// from_list([1, 2, 3]) |> insert_clamped(at: 5, this: 100)
/// // --> from_list([1, 2, 3, 100])
///
/// from_list([1, 2, 3]) |> insert(at: -1, this: 0)
/// // --> from_list([0, 1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn insert_clamped(
  into array: Array(item),
  at index: Int,
  this item: item,
) -> Array(item) {
  case size(array) {
    _ if index <= 0 -> prepend(array, item)
    len if index >= len -> append(array, item)
    _ -> {
      let #(before, after) = split(array, index)
      concat(direct_concat(before, wrap(item)), after)
    }
  }
}

/// Insert all elements in a given list to the array at a specific index,
/// in the same order they appear in the list.
///
/// This is more efficient than inserting all elements individually.
///
/// This function runs in _O(n)_ time, only depending on the size of the inserted list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> insert_list(at: 1, these: [34, 35])
/// // --> Ok(from_list([1, 34, 35, 2, 3]))
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn insert_list(
  into array: Array(item),
  at index: Int,
  these items: List(item),
) -> Result(Array(item), Nil) {
  case size(array) {
    len if 0 <= index && index <= len -> {
      let #(before, after) = split(array, index)
      Ok(concat(direct_concat(before, from_list(items)), after))
    }
    _ -> constants.error_nil
  }
}

/// Insert elements at an index into the array, moving all existing elements.
/// If the index is less than `0` prepend, and if it's greater than the number
/// of elements in the array append instead.
///
/// This is more efficient than inserting all elements individually.
///
/// This function runs in _O(n)_ time, only depending on the size of the inserted list.
///
/// ```gleam
/// from_list([1, 2, 3]) |> insert_list_clamped(at: 1, these: [34, 35])
/// // --> from_list([1, 34, 35, 2, 3])
///
/// from_list([1, 2, 3]) |> insert_list_clamped(at: 100, these: [100, 101])
/// // --> from_list([1, 2, 3, 100, 101])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn insert_list_clamped(
  into array: Array(item),
  at index: Int,
  these items: List(item),
) -> Array(item) {
  case size(array) {
    _ if index <= 0 -> prepend_list(array, items)
    len if index >= len -> append_list(array, items)
    _ -> {
      let #(before, after) = split(array, index)
      concat(direct_concat(before, from_list(items)), after)
    }
  }
}

/// Remove the element at a given index, moving all subsequent elements
/// to the left.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3]) |> delete(at: 1)
/// // --> Ok(from_list([1, 3]))
///
/// from_list([1, 2, 3]) |> delete(at: 3)
/// // --> Error(Nil)
///
/// from_list([]) |> delete(at: 0)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn delete(
  from array: Array(item),
  at index: Int,
) -> Result(Array(item), Nil) {
  case 0 <= index && index < size(array) {
    True -> Ok(concat(take_first(array, index), drop_first(array, index + 1)))
    False -> constants.error_nil
  }
}

/// Remove the element at a given index by swapping it with the last element,
/// then removing the last element. This is more efficient than `delete` but
/// does not preserve the order of elements.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3, 4]) |> swap_delete(at: 1)
/// // --> Ok(from_list([1, 4, 3]))
///
/// from_list([1, 2, 3]) |> swap_delete(at: 3)
/// // --> Error(Nil)
///
/// from_list([]) |> swap_delete(at: 0)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn swap_delete(
  from array: Array(item),
  at index: Int,
) -> Result(Array(item), Nil) {
  case 0 <= index && index < size(array) {
    True -> Ok(try_swap_delete(array, index))
    False -> constants.error_nil
  }
}

/// Remove the element at a given index by swapping it with the last element,
/// then removing the last element. This is more efficient than `try_delete` but
/// does not preserve the order of elements. If the index does not exist, return
/// the array unchanged.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3, 4]) |> try_swap_delete(at: 1)
/// // --> from_list([1, 4, 3])
///
/// from_list([1, 2, 3]) |> try_swap_delete(at: 3)
/// // --> from_list([1, 2, 3])
///
/// from_list([]) |> try_swap_delete(at: 0)
/// // --> from_list([])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_swap_delete(from array: Array(item), at index: Int) -> Array(item) {
  case array {
    Array(shift:, root:) -> {
      let size = node.size(root)
      case 0 <= index && index < size {
        True -> {
          case node.split(shift, root, size - 1) {
            node.EmptyPrefix -> Empty
            node.Split(prefix:, prefix_shift:, suffix:, suffix_shift:) ->
              case index == size - 1 {
                True -> Array(shift: prefix_shift, root: prefix)
                False -> {
                  let last = node.get(suffix, suffix_shift, 0)
                  prefix
                  |> node.update(prefix_shift, _, index, fn(_) { last })
                  |> Array(shift: prefix_shift, root: _)
                }
              }
          }
        }
        False -> array
      }
    }
    Empty -> array
  }
}

/// Remove the element at a given index, moving all subsequent elements
/// to the left. If the index does not exist, return the array unchanged.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3]) |> try_delete(at: 1)
/// // --> from_list([1, 3])
///
/// from_list([1, 2, 3]) |> try_delete(at: 3)
/// // --> from_list([1, 2, 3])
///
/// from_list([]) |> try_delete(at: 0)
/// // --> from_list([])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_delete(from array: Array(item), at index: Int) -> Array(item) {
  case 0 <= index && index < size(array) {
    True -> concat(take_first(array, index), drop_first(array, index + 1))
    False -> array
  }
}

/// Replace a slice with a different array.
///
/// The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3, 4]) |> replace(at: 1, replace: 2, with: from_list([7, 8, 9]))
/// // --> Ok(from_list([1, 7, 8, 9, 4]))
///
/// from_list([1, 2, 3]) |> replace(at: 2, replace: 1, with: from_list([7, 8, 9]))
/// // --> Ok(from_list([1, 2, 7, 8, 9]))
///
/// from_list([1, 2, 3]) |> replace(at: 2, replace: 2, with: from_list([8, 8, 9]))
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn replace(
  from array: Array(item),
  at index: Int,
  replace count: Int,
  with replacements: Array(item),
) -> Result(Array(item), Nil) {
  splice(array, index, count, fn(_) { replacements })
}

/// Replace a slice using a function, returning the new elements.
///
/// The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// from_list([1, 2, 3, 4]) |> splice(at: 1, replace: 2, with: fn(slice) {
///   map(slice, fn(x) { x * 2 })
/// })
/// // --> Ok(from_list([1, 4, 6, 4]))
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn splice(
  from array: Array(item),
  at index: Int,
  replace count: Int,
  with replacer: fn(Array(item)) -> Array(item),
) -> Result(Array(item), Nil) {
  case 0 <= index && 0 <= count && index + count <= size(array) {
    True -> {
      let #(before, after) = split(array, index)
      let #(replace, after) = split(after, count)
      Ok(concat(direct_concat(before, replacer(replace)), after))
    }
    False -> constants.error_nil
  }
}

// -- CONCATENATE AND SPLIT-----------------------------------------------------

/// Concatenate two arrays.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// concat(from_list([1, 2, 3]), from_list([4, 5, 6]))
/// // --> from_list([1, 2, 3, 4, 5, 6])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn concat(left left: Array(item), right right: Array(item)) -> Array(item) {
  case left, right {
    Empty, _ -> right
    _, Empty -> left
    Array(root: root1, shift: shift1), Array(root: root2, shift: shift2) -> {
      let max_shift = case shift1 >= shift2 {
        True -> shift1
        False -> shift2
      }
      let roots = case node.concat(root1, shift1, root2, shift2) {
        node.OneNode(root) -> vector.singleton(root)
        node.TwoNodes(full:, partial:) -> vector.pair(full, partial)
      }
      array(max_shift, roots)
    }
  }
}

/// Direct concat tries to insert nodes into free slots without rebalancing.
/// This is efficient for append/prepend operations where one side is dense.
/// Falls back to regular concat when there are no free slots.
fn direct_concat(left: Array(item), right: Array(item)) -> Array(item) {
  case left, right {
    Empty, _ -> right
    _, Empty -> left
    Array(shift: left_shift, root: left), Array(shift: right_shift, root: right)
    -> {
      let shift = case left_shift > right_shift {
        True -> left_shift
        False -> right_shift
      }
      case node.direct_concat(left_shift, left, right_shift, right) {
        node.Concatenated(root) -> Array(shift:, root:)
        node.NoFreeSlot(left:, right:) -> array(shift, vector.pair(left, right))
      }
    }
  }
}

/// Concatenate many array, joining them up to form a single array.
///
/// This function runs in _O(n)_ time, only depending on the number of arrays.
///
/// ```gleam
/// concat_list([from_list([1]), new(), from_list([2, 3])])
/// // --> from_list([1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn concat_list(arrays: List(Array(item))) -> Array(item) {
  list.fold(arrays, Empty, concat)
}

/// Concatenate many arrays, joining them up to form a single array.
///
/// This function runs in _O(n)_ time, only depending on the number of arrays.
///
/// ```gleam
/// flatten(from_list([from_list([1]), new(), from_list([2, 3])]))
/// // --> from_list([1, 2, 3])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn flatten(arrays: Array(Array(item))) -> Array(item) {
  fold(arrays, Empty, concat)
}

/// Split an array in two before the given index.
///
/// If the list is not long enough to have the given index the before list will
/// be the input list, and the after list will be empty.
///
/// ```gleam
/// split(from_list([6, 7, 8, 9]), at: 0)
/// // --> #(new(), from_list([6, 7, 8, 9]))
///
/// split(from_list([6, 7, 8, 9]), at: 2)
/// // --> #(from_list([6, 7]), from_list([8, 9]))
///
/// split(from_list([6, 7, 8, 9]), at: 4)
/// // --> #(from_list([6, 7, 8, 9]), new())
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn split(array: Array(item), at index: Int) -> #(Array(item), Array(item)) {
  case array {
    Empty -> #(Empty, Empty)
    _ if index <= 0 -> #(Empty, array)
    Array(root:, shift:) ->
      case node.size(root) {
        length if index >= length -> #(array, Empty)
        _ ->
          case node.split(shift, root, index) {
            node.Split(prefix:, prefix_shift:, suffix:, suffix_shift:) -> {
              let prefix = Array(shift: prefix_shift, root: prefix)
              let suffix = Array(shift: suffix_shift, root: suffix)
              #(prefix, suffix)
            }
            node.EmptyPrefix -> #(Empty, array)
          }
      }
  }
}

/// Remove up to `n` elements from the start of the array.
///
/// If the array has less than `n` elements an empty array is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// drop_first(from_list([1, 2, 3, 4]), up_to: 2)
/// // --> from_list([3, 4])
///
/// drop_first(from_list([1, 2, 3, 4]), up_to: 5)
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn drop_first(from array: Array(item), up_to n: Int) -> Array(item) {
  case array {
    _ if n <= 0 -> array
    Empty -> Empty
    Array(root:, shift:) ->
      case n < node.size(root) {
        True ->
          case node.split(shift, root, n) {
            node.Split(prefix: _, suffix: root, suffix_shift:, ..) ->
              Array(shift: suffix_shift, root:)
            node.EmptyPrefix -> array
          }
        False -> Empty
      }
  }
}

/// Remove up to `n` elements from the end of the array.
///
/// If the array has less than `n` elements an empty array is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// drop_last(from_list([1, 2, 3, 4]), up_to: 2)
/// // --> from_list([1, 2])
///
/// drop_last(from_list([1, 2, 3, 4]), up_to: 5)
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn drop_last(from array: Array(item), up_to n: Int) -> Array(item) {
  take_first(array, size(array) - n)
}

/// Return up to the first `n` elements from the start of the array.
///
/// If the array has less than `n` elements, the original array is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// take_first(from_list([6, 7, 8, 9]), up_to: 3)
/// // --> from_list([6, 7, 8])
///
/// take_first(from_list([6, 7, 8, 9]), up_to: 10)
/// // --> from_list([6, 7, 8, 9])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn take_first(from array: Array(item), up_to n: Int) -> Array(item) {
  case array {
    _ if n <= 0 -> Empty
    Empty -> Empty
    Array(root:, shift:) ->
      case n < node.size(root) {
        True ->
          case node.split(shift, root, n) {
            node.Split(prefix: root, prefix_shift:, ..) ->
              Array(shift: prefix_shift, root:)
            node.EmptyPrefix -> Empty
          }
        False -> array
      }
  }
}

/// Return up `n` elements from the end of the array.
///
/// If the array has less than `n` elements, the original array is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// take_last(from_list([6, 7, 8, 9]), up_to: 3)
/// // --> from_list([7, 8, 9])
///
/// take_last(from_list([6, 7, 8, 9]), up_to: 10)
/// // --> from_list([6, 7, 8, 9])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn take_last(from array: Array(item), up_to n: Int) -> Array(item) {
  drop_first(array, size(array) - n)
}

/// Returns an array of chunks containing `count` elements each.
///
/// If the last chunk does not have count elements, it is instead a partial
/// chunk, with less than count elements.
///
/// For any count less than 1 this function behaves as if it was set to 1.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn sized_chunk(in array: Array(item), into count: Int) -> Array(Array(item)) {
  sized_chunk_loop(array, int.min(1, count), [])
}

fn sized_chunk_loop(
  array: Array(item),
  count: Int,
  chunks: List(Array(item)),
) -> Array(Array(item)) {
  let size = size(array)
  case size <= count {
    True ->
      case size {
        0 -> from_reverse_list(chunks)
        _ -> from_reverse_list([array, ..chunks])
      }
    False -> {
      let #(chunk, rest) = split(array, count)
      sized_chunk_loop(rest, count, [chunk, ..chunks])
    }
  }
}

/// Returns an array distributing its elements evenly into `n` chunks.
///
/// If there are less than `n` elements in the array, less chunks may be
/// returned.
///
/// For any count less than 1 this function behaves as if it was set to 1.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn split_n(in array: Array(item), into n_chunks: Int) -> Array(Array(item)) {
  split_n_loop(array, size(array) / n_chunks, size(array) % n_chunks, [])
}

fn split_n_loop(array, count, rest, chunks) {
  let size = size(array)
  case size <= count {
    True ->
      case size {
        0 -> from_reverse_list(chunks)
        _ -> from_reverse_list([array, ..chunks])
      }
    False -> {
      let #(chunk, array) = case rest > 0 {
        False -> split(array, count)
        True -> split(array, count + 1)
      }
      split_n_loop(array, count, rest - 1, [chunk, ..chunks])
    }
  }
}

/// Return the array without the first element. If the array is empty,
/// `Error(Nil)` is returned.
///
/// ```gleam
/// rest(from_list([1, 2, 3]))
/// // --> Ok(from_list([2, 3]))
///
/// rest(new())
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use drop_first(1) instead.")
pub fn rest(array: Array(item)) -> Result(Array(item), Nil) {
  case array {
    Empty -> constants.error_nil
    Array(..) -> Ok(drop_first(array, 1))
  }
}

/// Return the array without the last element. If the array is empty,
/// `Error(Nil)` is returned.
///
/// ```gleam
/// leading(from_list([1, 2, 3]))
/// // --> Ok(from_list([1, 2]))
///
/// leading(new())
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
@deprecated("use drop_last(1) instead.")
pub fn leading(array: Array(item)) -> Result(Array(item), Nil) {
  case array {
    Empty -> constants.error_nil
    Array(..) -> Ok(drop_last(array, 1))
  }
}

/// Extract a sub-slice from the array. If the start is not part of the
/// array or if the array does not contain enough elements, `Error(Nil)` is returned.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// let array = from_list([6, 7, 8, 9])
///
/// slice(from: array, start: 1, size: 2)
/// // --> Ok(from_list([7, 8]))
///
/// slice(from: array, start: 2, size: 3)
/// // --> Error(Nil)
///
/// slice(from: array, start: 5, size: 0)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn slice(
  from array: Array(item),
  start start: Int,
  size size: Int,
) -> Result(Array(item), Nil) {
  case array {
    Empty if size == 0 -> Ok(Empty)
    Empty -> constants.error_nil
    Array(root:, ..) ->
      case 0 <= start && start + size <= node.size(root) {
        True -> Ok(slice_clamped(array, start, size))
        False -> constants.error_nil
      }
  }
}

/// Extract a sub-slice from the array.
///
/// This function runs in _O(log n)_ time.
///
/// ```gleam
/// let array = from_list([6, 7, 8, 9])
///
/// slice_clamped(from: array, start: 1, size: 2)
/// // --> from_list([7, 8])
///
/// slice_clamped(from: array, start: 2, size: 3)
/// // --> from_list([8, 9])
///
/// slice_clamped(from: array, start: 5, size: 0)
/// // --> from_list([])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn slice_clamped(
  from array: Array(item),
  start start: Int,
  size size: Int,
) -> Array(item) {
  let #(_, array) = split(array, start)
  let #(array, _) = split(array, size)
  array
}

// -- TRANSFORM ----------------------------------------------------------------

/// Create a new array containing the same elements, but in the opposite order.
///
/// ```gleam
/// reverse(from_list([6, 7, 8]))
/// // --> from_list([8, 7, 6])
///
/// reverse(from_list([1]))
/// // --> from_list([1])
///
/// reverse(new())
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn reverse(items: Array(item)) -> Array(item) {
  case
    items
    |> fold_right(builder.new(), builder.push)
    |> builder.build
  {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Return a copy of the array, where each element is replaced by the result
/// of a function.
///
/// ```gleam
/// map(from_list([6, 7, 8]), fn(x) { x * 2 })
/// // --> from_list([12, 14, 16])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn map(array: Array(a), with fun: fn(a) -> b) -> Array(b) {
  case array {
    Empty -> Empty
    Array(root:, shift:) -> Array(shift:, root: node.map(root, fun))
  }
}

/// Return a copy of the array, where each element is replaced by the result
/// of applying a function to the index and the element at that index.
///
/// ```gleam
/// index_map(from_list([6, 7, 8]), fn(x, i) { #(i, x) })
/// // --> from_list([#(0, 6), #(1, 7), #(2, 8)])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn index_map(array: Array(a), with fun: fn(a, Int) -> b) -> Array(b) {
  case array {
    Empty -> Empty
    Array(root:, shift:) ->
      Array(shift:, root: node.index_map(shift, 0, root, fun))
  }
}

/// Return a copy of the array, where each element is replaced by the `Ok(_)`
/// result of applying a function to each element.
///
/// If the fuction returns `Error(_)` for any of the elements, that error is
/// immediately returned instead.
///
/// ```gleam
/// try_map(from_list([[1], [2, 3]]), list.first)
/// // --> Ok(from_list([1, 2]))
///
/// try_map(from_list([[1], [], [2, 3]]), list.first)
/// // --> Error(Nil)
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_map(
  over array: Array(a),
  with fun: fn(a) -> Result(b, e),
) -> Result(Array(b), e) {
  case array {
    Empty -> Ok(Empty)
    Array(root:, shift:) ->
      case node.try_map(root, fun) {
        Ok(root) -> Ok(Array(root:, shift:))
        Error(error) -> Error(error)
      }
  }
}

/// Map every element in the array to a new array, and then flatten them.
///
/// ```gleam
/// flat_map(from_list([2, 4, 6]), fn(x) { from_list([x, x + 1]) })
/// // --> from_list([2, 3, 4, 5, 6, 7])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn flat_map(array: Array(a), with fun: fn(a) -> Array(b)) -> Array(b) {
  use result, item <- fold(array, Empty)
  concat(result, fun(item))
}

/// Build a new array containing only the elements for which the given function
/// returns `True`.
///
/// ```gleam
/// filter(from_list([1, 2, 3, 4]), int.is_even)
/// // --> from_list([2, 4])
///
/// filter(from_list([1, 2, 3, 4]), fn(x) { x > 6 })
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn filter(items: Array(a), keeping predicate: fn(a) -> Bool) -> Array(a) {
  let result =
    builder.build({
      use builder, item <- fold(items, builder.new())
      case predicate(item) {
        True -> builder.push(builder, item)
        False -> builder
      }
    })

  case result {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Build a new array containing only the values for which the given function
/// returns `Ok(_)`.
///
/// ```gleam
/// filter_map(from_list([[], [1], [2, 3]]), list.first)
/// // --> from_list([1, 2])
///
/// filter_map(from_list([1, 2, 3]), Error)
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn filter_map(items: Array(a), with fun: fn(a) -> Result(b, c)) -> Array(b) {
  let result =
    builder.build({
      use builder, item <- fold(items, builder.new())
      case fun(item) {
        Ok(new_item) -> builder.push(builder, new_item)
        Error(_) -> builder
      }
    })

  case result {
    Ok(#(shift, nodes)) -> array(shift, nodes)
    Error(_) -> Empty
  }
}

/// Combine 2 arrays into a single array using the given function.
///
/// If one array is longer than the other, the extra elements are dropped from
/// the end.
///
/// ```gleam
/// map2(from_list([1, 2, 3]), from_list([4, 5, 6]), int.add)
/// // --> from_list([5, 7, 9])
///
/// map2(from_list([1, 2]), from_list(["a", "b", "c"]), fn(a, b) { #(a, b) })
/// // --> from_list([#(1, "a"), #(2, "b")])
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn map2(a: Array(a), b: Array(b), with fun: fn(a, b) -> c) -> Array(c) {
  yielder.map2(to_yielder(a), to_yielder(b), fun)
  |> from_yielder
}

/// Combine 2 arrays into a single array of 2-element tuples.
///
/// If one array is longer than the other, the extra elements are dropped from
/// the end.
///
/// ```gleam
/// zip(from_list([1, 2, 3]), from_list(["a", "b", "c"]))
/// // --> from_list([#(1, "a"), #(2, "b"), #(3, "c")])
///
/// zip(from_list([]), from_list(["a", "b", "c"]))
/// // --> new()
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn zip(a: Array(a), b: Array(b)) -> Array(#(a, b)) {
  map2(a, b, fn(a, b) { #(a, b) })
}

// -- LOOPING ------------------------------------------------------------------

/// Loop through the elements from the start to the end, calling a function
/// and discarding the result.
///
/// Useful for performing some side-effects for every element.
///
/// ```gleam
/// use item <- each(from_list([1, 2, 3]))
/// io.println(int.to_string(item))
/// // 1
/// // 2
/// // 3
/// // --> Nil
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn each(in array: Array(item), do something: fn(item) -> a) -> Nil {
  use Nil, item <- fold(array, Nil)
  something(item)
  Nil
}

/// Loop through the elements from the start to the end, calling a
/// result-returning function for all of them. As soon as the function returns
/// `Error(_)`, iteration is stopped and the error is returned.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_each(
  in array: Array(item),
  do something: fn(item) -> Result(a, e),
) -> Result(Nil, e) {
  use Nil, item <- try_fold(array, Nil)
  case something(item) {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
}

/// Loop through the elements in reverse order from the end to the start,
/// calling a function on each element and discarding the result.
///
/// Useful for performing some side-effects for every element.
///
/// ```gleam
/// use item <- each(from_list([1, 2, 3]))
/// io.println(int.to_string(item))
/// // 3
/// // 2
/// // 1
/// // --> Nil
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn each_right(in array: Array(item), do something: fn(item) -> a) -> Nil {
  use Nil, item <- fold_right(array, Nil)
  something(item)
  Nil
}

/// Build up a new value by looping through each of the elements from the start
/// to the end.
///
/// ```gleam
/// fold(from_list([6, 7, 8]), from: 0, with: int.add)
/// // --> 21
///
/// fold(from_list([6, 7, 8]), from: [], with: list.prepend)
/// // --> [8, 7, 6]
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn fold(
  over array: Array(item),
  from state: state,
  with fun: fn(state, item) -> state,
) -> state {
  case array {
    Empty -> state
    Array(root:, ..) -> node.fold(root, state, fun)
  }
}

/// Like `fold`, but also passes the index of the current element.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn index_fold(
  over array: Array(item),
  from state: state,
  with fun: fn(state, item, Int) -> state,
) -> state {
  case array {
    Empty -> state
    Array(root:, shift:) -> node.index_fold(shift, 0, root, state, fun)
  }
}

/// Build up a new value by looping in reverse from the end to the start through
/// the array.
///
/// ```gleam
/// fold_right(from_list([6, 7, 8]), from: 0, with: int.add)
/// // --> 21
///
/// fold_right(from_list([6, 7, 8]), from: [], with: list.prepend)
/// // --> [6, 7, 8]
/// ```
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn fold_right(
  over array: Array(item),
  from state: state,
  with fun: fn(state, item) -> state,
) {
  case array {
    Empty -> state
    Array(root:, ..) -> node.fold_right(root, state, fun)
  }
}

/// Like `fold`, but pass the current index to the accumulator function.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn index_fold_right(
  over array: Array(item),
  from state: state,
  with fun: fn(state, item, Int) -> state,
) {
  case array {
    Empty -> state
    Array(root:, shift:) -> node.index_fold_right(shift, 0, root, state, fun)
  }
}

/// A variant of `fold` that builds up a new value using a function that can
/// fail.
///
/// If the function returns `Error(_)`, iteration is stopped and the error is
/// returned immediately. Otherwise, the final built-up value is returned.
///
/// <div style="text-align: right;">
///     <a href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
pub fn try_fold(
  over array: Array(item),
  from state: state,
  with fun: fn(state, item) -> Result(state, error),
) -> Result(state, error) {
  case array {
    Empty -> Ok(state)
    Array(root:, ..) -> node.try_fold(root, state, fun)
  }
}
