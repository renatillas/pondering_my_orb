import * as $dict from "../../gleam_stdlib/gleam/dict.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import { None, Some } from "../../gleam_stdlib/gleam/option.mjs";
import * as $order from "../../gleam_stdlib/gleam/order.mjs";
import { Eq, Gt, Lt } from "../../gleam_stdlib/gleam/order.mjs";
import * as $set from "../../gleam_stdlib/gleam/set.mjs";
import { Ok, CustomType as $CustomType, isEqual } from "../gleam.mjs";

class Bag extends $CustomType {
  constructor(map) {
    super();
    this.map = map;
  }
}

/**
 * Creates a new empty bag.
 */
export function new$() {
  return new Bag($dict.new$());
}

/**
 * Creates a new bag from the map where each key/value pair is turned into
 * an item with those many copies inside the bag.
 *
 * ## Examples
 *
 * ```gleam
 * map.from_list([#("a", 1), #("b", 2)])
 * |> bag.from_map
 * |> bag.to_list
 * // [#("a", 1), #("b", 2)]
 * ```
 */
export function from_map(map) {
  return new Bag(map);
}

/**
 * Removes all the copies of a given item from a bag.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a"])
 * |> bag.remove_all("a")
 * |> bag.to_list
 * // [#(b, 1)]
 * ```
 */
export function remove_all(bag, item) {
  return new Bag($dict.delete$(bag.map, item));
}

/**
 * Counts the number of copies of an item inside a bag.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "c"])
 * |> bag.copies(of: "a")
 * // 2
 * ```
 */
export function copies(bag, item) {
  let $ = $dict.get(bag.map, item);
  if ($ instanceof Ok) {
    let copies$1 = $[0];
    return copies$1;
  } else {
    return 0;
  }
}

/**
 * Removes `n` copies of the given item from a bag.
 *
 * If the quantity to remove is greater than the number of copies in the bag,
 * all copies of that item are removed.
 *
 * > ⚠️ Giving a negative quantity to remove doesn't really make sense, so the
 * > sign of the `copies` argument is always ignored.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "a"])
 * |> bag.remove(1, "a")
 * |> bag.copies(of: "a")
 * // 1
 * ```
 *
 * ```gleam
 * bag.from_list(["a", "a"])
 * |> bag.remove(-1, "a")
 * |> bag.copies(of: "a")
 * // 1
 * ```
 *
 * ```gleam
 * bag.from_list(["a", "a"])
 * |> bag.remove(10, "a")
 * |> bag.copies(of: "a")
 * // 0
 * ```
 */
export function remove(bag, to_remove, item) {
  let to_remove$1 = $int.absolute_value(to_remove);
  let item_copies = copies(bag, item);
  let $ = $int.compare(to_remove$1, item_copies);
  if ($ instanceof Lt) {
    return new Bag($dict.insert(bag.map, item, item_copies - to_remove$1));
  } else if ($ instanceof Eq) {
    return remove_all(bag, item);
  } else {
    return remove_all(bag, item);
  }
}

/**
 * Adds `n` copies of the given item into a bag.
 *
 * If the number of copies to add is negative, then this is the same as calling
 * [`remove`](#remove) and will remove that many copies from the bag.
 *
 * ## Examples
 *
 * ```gleam
 * bag.new()
 * |> bag.insert(2, "a")
 * |> bag.copies(of: "a")
 * // 2
 * ```
 *
 * ```gleam
 * bag.from_list(["a"])
 * |> bag.insert(-1, "a")
 * |> bag.copies(of: "a")
 * // 0
 * ```
 */
export function insert(bag, to_add, item) {
  let $ = $int.compare(to_add, 0);
  if ($ instanceof Lt) {
    return remove(bag, to_add, item);
  } else if ($ instanceof Eq) {
    return bag;
  } else {
    return new Bag(
      $dict.upsert(
        bag.map,
        item,
        (n) => {
          if (n instanceof Some) {
            let n$1 = n[0];
            return n$1 + to_add;
          } else {
            return to_add;
          }
        },
      ),
    );
  }
}

/**
 * Creates a new bag from the given list by counting its items.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "c"])
 * |> bag.to_list
 * // [#("a", 2), #("b", 1), #("c", 1)]
 * ```
 */
export function from_list(list) {
  return $list.fold(
    list,
    new$(),
    (bag, item) => { return insert(bag, 1, item); },
  );
}

/**
 * Updates the number of copies of an item in the bag.
 *
 * If the function returns 0 or a negative number, the item is removed from
 * the bag.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a"])
 * |> bag.update("a", fn(n) { n + 1 })
 * |> bag.copies(of: "a")
 * // 2
 * ```
 *
 * ```gleam
 * bag.new()
 * |> bag.update("a", fn(_) { 10 })
 * |> bag.copies(of: "a")
 * // 10
 * ```
 *
 * ```gleam
 * bag.from_list(["a"])
 * |> bag.update("a", fn(_) { -1 })
 * |> bag.copies(of: "a")
 * // 0
 * ```
 */
export function update(bag, item, fun) {
  let count = copies(bag, item);
  let new_count = fun(count);
  let $ = $int.compare(new_count, 0);
  if ($ instanceof Lt) {
    return remove_all(bag, item);
  } else if ($ instanceof Eq) {
    return remove_all(bag, item);
  } else {
    let _pipe = remove_all(bag, item);
    return insert(_pipe, new_count, item);
  }
}

/**
 * Returns `True` if the bag contains at least a copy of the given item.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b"])
 * |> bag.contains("a")
 * // True
 * ```
 *
 * ```gleam
 * bag.from_list(["a", "b"])
 * |> bag.contains("c")
 * // False
 * ```
 */
export function contains(bag, item) {
  return $dict.has_key(bag.map, item);
}

/**
 * Returns `True` if the bag is empty.
 *
 * > ⚠️ This is more efficient than checking if the bag's size is 0.
 * > You should always use this function to check that a bag is empty!
 *
 * ## Examples
 *
 * ```gleam
 * bag.new()
 * |> bag.is_empty()
 * // True
 * ```
 *
 * ```gleam
 * bag.from_list(["a", "b"])
 * |> bag.is_empty()
 * // False
 * ```
 */
export function is_empty(bag) {
  return isEqual(bag.map, $dict.new$());
}

/**
 * Combines all items of a bag into a single value by calling a given function
 * on each one.
 *
 * The function will receive as input the accumulator, the item and
 * its number of copies.
 *
 * ## Examples
 *
 * ```gleam
 * let bag = bag.from_list(["a", "b", "b"])
 * bag.fold(over: bag, from: 0, with: fn(count, _, copies) {
 *   count + copies
 * })
 * // 3
 * ```
 */
export function fold(bag, initial, fun) {
  return $dict.fold(bag.map, initial, fun);
}

/**
 * Returns the total number of items inside a bag.
 *
 * > ⚠️ This function takes linear time in the number of distinct items in the
 * > bag.
 * >
 * > If you need to check that a bag is empty, you should always use the
 * > [`is_empty`](#is_empty) function instead of checking if the size is 0.
 * > It's going to be way more efficient!
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "c"])
 * |> bag.size
 * // 4
 * ```
 */
export function size(bag) {
  return fold(bag, 0, (sum, _, copies) => { return sum + copies; });
}

/**
 * Intersects two bags keeping the minimum number of copies of each item
 * that appear in both bags.
 *
 * ## Examples
 *
 * ```gleam
 * let bag1 = bag.from_list(["a", "a", "b", "c"])
 * let bag2 = bag.from_list(["a", "c", "c"])
 *
 * bag.intersect(bag1, bag2)
 * |> bag.to_list
 * // [#("a", 1), #("c", 1)]
 * ```
 */
export function intersect(one, other) {
  return fold(
    one,
    new$(),
    (acc, item, copies_in_one) => {
      let $ = copies(other, item);
      if ($ === 0) {
        return acc;
      } else {
        let copies_in_other = $;
        return insert(acc, $int.min(copies_in_one, copies_in_other), item);
      }
    },
  );
}

/**
 * Adds all the items of two bags together.
 *
 * ## Examples
 *
 * ```gleam
 * let bag1 = bag.from_list(["a", "b"])
 * let bag2 = bag.from_list(["b", "c"])
 *
 * bag.merge(bag1, bag2)
 * |> bag.to_list
 * // [#("a", 1), #("b", 2), #("c", 1)]
 * ```
 */
export function merge(one, other) {
  return fold(
    one,
    other,
    (acc, item, copies_in_one) => { return insert(acc, copies_in_one, item); },
  );
}

/**
 * Removes all items of the second bag from the first one.
 *
 * ## Examples
 *
 * ```gleam
 * let bag1 = bag.from_list(["a", "b", "b"])
 * let bag2 = bag.from_list(["b", "c"])
 *
 * bag.subtract(from: one, items_of: other)
 * |> bag.to_list
 * // [#("a", 1), #("b", 1)]
 * ```
 */
export function subtract(one, other) {
  return fold(
    other,
    one,
    (acc, item, copies_in_other) => {
      return remove(acc, copies_in_other, item);
    },
  );
}

/**
 * Updates all values of a bag calling on each a function that takes as
 * argument the item and its number of copies.
 *
 * If one or more items are mapped to the same item, their occurrences are
 * summed up.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "b"])
 * |> bag.map(fn(item, _) { "c" })
 * |> bag.to_list
 * // [#("c", 3)]
 * ```
 */
export function map(bag, fun) {
  return fold(
    bag,
    new$(),
    (acc, item, copies) => { return insert(acc, copies, fun(item, copies)); },
  );
}

/**
 * Only keeps the items of a bag the respect a given predicate that takes as
 * input an item and the number of its copies.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "b", "c", "d"])
 * |> bag.filter(keeping: fn(_, copies) { copies <= 1 })
 * |> bag.to_list
 * // [#("c", 1), #("d", 1)]
 * ```
 */
export function filter(bag, predicate) {
  return fold(
    bag,
    new$(),
    (acc, item, copies) => {
      let $ = predicate(item, copies);
      if ($) {
        return insert(acc, copies, item);
      } else {
        return acc;
      }
    },
  );
}

/**
 * Turns a `Bag` into a list of items and their respective number of copies in
 * the bag.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "c"])
 * |> bag.to_list
 * // [#("a", 2), #("b", 1), #("c", 1)]
 * ```
 */
export function to_list(bag) {
  return $dict.to_list(bag.map);
}

/**
 * Turns a `Bag` into a set of its items, losing all information on their
 * number of copies.
 *
 * ## Examples
 *
 * ```gleam
 * bag.from_list(["a", "b", "a", "c"])
 * |> bag.to_set
 * // set.from_list(["a", "b", "c"])
 * ```
 */
export function to_set(bag) {
  return $set.from_list($dict.keys(bag.map));
}

/**
 * Turns a `Bag` into a map. Each item in the bag becomes a key and the
 * associated value is the number of its copies in the bag.
 */
export function to_map(bag) {
  return bag.map;
}
