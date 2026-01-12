import {
  Ok,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
  makeError,
} from "../../gleam.mjs";
import * as $constants from "../../iv/internal/constants.mjs";
import * as $vector from "../../iv/internal/vector.mjs";
import { bsl as bitwise_shift_left, bsr as bitwise_shift_right } from "../../iv_ffi.mjs";

const FILEPATH = "src/iv/internal/node.gleam";

/**
 * Balanced sub-trees are left-full.
 */
export class Balanced extends $CustomType {
  constructor(size, children) {
    super();
    this.size = size;
    this.children = children;
  }
}
export const Node$Balanced = (size, children) => new Balanced(size, children);
export const Node$isBalanced = (value) => value instanceof Balanced;
export const Node$Balanced$size = (value) => value.size;
export const Node$Balanced$0 = (value) => value.size;
export const Node$Balanced$children = (value) => value.children;
export const Node$Balanced$1 = (value) => value.children;

/**
 * Unbalanced sub-trees are less-than left-full.
 */
export class Unbalanced extends $CustomType {
  constructor(sizes, children) {
    super();
    this.sizes = sizes;
    this.children = children;
  }
}
export const Node$Unbalanced = (sizes, children) =>
  new Unbalanced(sizes, children);
export const Node$isUnbalanced = (value) => value instanceof Unbalanced;
export const Node$Unbalanced$sizes = (value) => value.sizes;
export const Node$Unbalanced$0 = (value) => value.sizes;
export const Node$Unbalanced$children = (value) => value.children;
export const Node$Unbalanced$1 = (value) => value.children;

export class Leaf extends $CustomType {
  constructor(children) {
    super();
    this.children = children;
  }
}
export const Node$Leaf = (children) => new Leaf(children);
export const Node$isLeaf = (value) => value instanceof Leaf;
export const Node$Leaf$children = (value) => value.children;
export const Node$Leaf$0 = (value) => value.children;

/**
 * Successfully merged into a single node
 */
export class OneNode extends $CustomType {
  constructor(node) {
    super();
    this.node = node;
  }
}
export const ConcatResult$OneNode = (node) => new OneNode(node);
export const ConcatResult$isOneNode = (value) => value instanceof OneNode;
export const ConcatResult$OneNode$node = (value) => value.node;
export const ConcatResult$OneNode$0 = (value) => value.node;

/**
 * Requires two nodes: first is full, second has remaining children
 */
export class TwoNodes extends $CustomType {
  constructor(full, partial) {
    super();
    this.full = full;
    this.partial = partial;
  }
}
export const ConcatResult$TwoNodes = (full, partial) =>
  new TwoNodes(full, partial);
export const ConcatResult$isTwoNodes = (value) => value instanceof TwoNodes;
export const ConcatResult$TwoNodes$full = (value) => value.full;
export const ConcatResult$TwoNodes$0 = (value) => value.full;
export const ConcatResult$TwoNodes$partial = (value) => value.partial;
export const ConcatResult$TwoNodes$1 = (value) => value.partial;

class RebalanceState extends $CustomType {
  constructor(balance, subtrees, overflow, overflow_length) {
    super();
    this.balance = balance;
    this.subtrees = subtrees;
    this.overflow = overflow;
    this.overflow_length = overflow_length;
  }
}

/**
 * Left tree with merged result from recursive concat.
 * 
 * @ignore
 */
class FromLeft extends $CustomType {
  constructor(left, merged) {
    super();
    this.left = left;
    this.merged = merged;
  }
}

/**
 * Right tree with merged result from recursive concat.
 * 
 * @ignore
 */
class FromRight extends $CustomType {
  constructor(merged, right) {
    super();
    this.merged = merged;
    this.right = right;
  }
}

/**
 * Equal height merge with three parts.
 * 
 * @ignore
 */
class RebalanceMerge extends $CustomType {
  constructor(left, merged, right) {
    super();
    this.left = left;
    this.merged = merged;
    this.right = right;
  }
}

export class Concatenated extends $CustomType {
  constructor(merged) {
    super();
    this.merged = merged;
  }
}
export const DirectConcatResult$Concatenated = (merged) =>
  new Concatenated(merged);
export const DirectConcatResult$isConcatenated = (value) =>
  value instanceof Concatenated;
export const DirectConcatResult$Concatenated$merged = (value) => value.merged;
export const DirectConcatResult$Concatenated$0 = (value) => value.merged;

export class NoFreeSlot extends $CustomType {
  constructor(left, right) {
    super();
    this.left = left;
    this.right = right;
  }
}
export const DirectConcatResult$NoFreeSlot = (left, right) =>
  new NoFreeSlot(left, right);
export const DirectConcatResult$isNoFreeSlot = (value) =>
  value instanceof NoFreeSlot;
export const DirectConcatResult$NoFreeSlot$left = (value) => value.left;
export const DirectConcatResult$NoFreeSlot$0 = (value) => value.left;
export const DirectConcatResult$NoFreeSlot$right = (value) => value.right;
export const DirectConcatResult$NoFreeSlot$1 = (value) => value.right;

export class Split extends $CustomType {
  constructor(prefix, prefix_shift, suffix, suffix_shift) {
    super();
    this.prefix = prefix;
    this.prefix_shift = prefix_shift;
    this.suffix = suffix;
    this.suffix_shift = suffix_shift;
  }
}
export const SplitResult$Split = (prefix, prefix_shift, suffix, suffix_shift) =>
  new Split(prefix, prefix_shift, suffix, suffix_shift);
export const SplitResult$isSplit = (value) => value instanceof Split;
export const SplitResult$Split$prefix = (value) => value.prefix;
export const SplitResult$Split$0 = (value) => value.prefix;
export const SplitResult$Split$prefix_shift = (value) => value.prefix_shift;
export const SplitResult$Split$1 = (value) => value.prefix_shift;
export const SplitResult$Split$suffix = (value) => value.suffix;
export const SplitResult$Split$2 = (value) => value.suffix;
export const SplitResult$Split$suffix_shift = (value) => value.suffix_shift;
export const SplitResult$Split$3 = (value) => value.suffix_shift;

export class EmptyPrefix extends $CustomType {}
export const SplitResult$EmptyPrefix = () => new EmptyPrefix();
export const SplitResult$isEmptyPrefix = (value) =>
  value instanceof EmptyPrefix;

export const branch_bits = 5;

export const branch_factor = 32;

/**
 * Maximum extra search steps allowed in relaxed nodes.
 * According to Bagwell & Rompf's RRB-Vector research, E=2 provides a good
 * balance between indexing efficiency and concatenation cost.
 * This implements the Search Step Invariant: S ≤ ⌈P/M⌉ + E
 * where S is slots, P is items, M is branch_factor, and E is e_max.
 * 
 * @ignore
 */
const e_max = 2;

/**
 * Size is the number of _individual values_ stored in this node.
 */
export function size(node) {
  if (node instanceof Balanced) {
    let size$1 = node.size;
    return size$1;
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    return $vector.get($vector.length(sizes), sizes);
  } else {
    let children = node.children;
    return $vector.length(children);
  }
}

function compute_sizes(nodes) {
  let first_size = size($vector.get(1, nodes));
  return $vector.fold_skip_first(
    nodes,
    $vector.singleton(first_size),
    (sizes, node) => {
      let size$1 = $vector.get($vector.length(sizes), sizes) + size(node);
      return $vector.append(sizes, size$1);
    },
  );
}

/**
 * Length is the number of _direct children_ this node has
 * 
 * @ignore
 */
function length(node) {
  if (node instanceof Balanced) {
    let children = node.children;
    return $vector.length(children);
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return $vector.length(children);
  } else {
    let children = node.children;
    return $vector.length(children);
  }
}

function find_size(loop$sizes, loop$size_idx_plus_one, loop$index) {
  while (true) {
    let sizes = loop$sizes;
    let size_idx_plus_one = loop$size_idx_plus_one;
    let index = loop$index;
    let $ = $vector.get(size_idx_plus_one, sizes) > index;
    if ($) {
      return size_idx_plus_one - 1;
    } else {
      loop$sizes = sizes;
      loop$size_idx_plus_one = size_idx_plus_one + 1;
      loop$index = index;
    }
  }
}

export function find_map(node, fun) {
  if (node instanceof Balanced) {
    let children = node.children;
    return $vector.find_map(
      children,
      (_capture) => { return find_map(_capture, fun); },
    );
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return $vector.find_map(
      children,
      (_capture) => { return find_map(_capture, fun); },
    );
  } else {
    let children = node.children;
    return $vector.find_map(children, fun);
  }
}

function concat_result_to_vector(result) {
  if (result instanceof OneNode) {
    let node = result.node;
    return $vector.singleton(node);
  } else {
    let full = result.full;
    let partial = result.partial;
    return $vector.pair(full, partial);
  }
}

function concat_result_node_count(result) {
  if (result instanceof OneNode) {
    return 1;
  } else {
    return 2;
  }
}

function sum_children_counts(count, node) {
  if (node instanceof Balanced) {
    let children = node.children;
    return count + $vector.length(children);
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return count + $vector.length(children);
  } else {
    let children = node.children;
    return count + $vector.length(children);
  }
}

function concat_result_children_count(result) {
  if (result instanceof OneNode) {
    let node = result.node;
    return sum_children_counts(0, node);
  } else {
    let full = result.full;
    let partial = result.partial;
    return sum_children_counts(sum_children_counts(0, full), partial);
  }
}

function sum_node_children_counts_skip_first(nodes) {
  return $vector.fold_skip_first(nodes, 0, sum_children_counts);
}

function sum_node_children_counts_skip_last(nodes) {
  return $vector.fold_skip_last(nodes, 0, sum_children_counts);
}

function extract_children(node) {
  if (node instanceof Balanced) {
    let children = node.children;
    return children;
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return children;
  } else {
    throw makeError(
      "panic",
      FILEPATH,
      "iv/internal/node",
      595,
      "extract_children",
      "`panic` expression evaluated.",
      {}
    )
  }
}

function extract_items(node) {
  let children;
  if (node instanceof Leaf) {
    children = node.children;
  } else {
    throw makeError(
      "let_assert",
      FILEPATH,
      "iv/internal/node",
      600,
      "extract_items",
      "Pattern match failed, no pattern matched the value.",
      {
        value: node,
        start: 19565,
        end: 19597,
        pattern_start: 19576,
        pattern_end: 19590
      }
    )
  }
  return children;
}

function rebalance_skip_subtree(state, children) {
  return new RebalanceState(
    state.balance - 1,
    state.subtrees,
    listPrepend(children, state.overflow),
    $vector.length(children) + state.overflow_length,
  );
}

function rebalance_push_subtree(state, subtree, overflow, overflow_length) {
  return new RebalanceState(
    state.balance,
    $vector.append(state.subtrees, subtree),
    overflow,
    overflow_length,
  );
}

export function map(node, fun) {
  if (node instanceof Balanced) {
    let size$1 = node.size;
    let children = node.children;
    return new Balanced(
      size$1,
      $vector.map(children, (_capture) => { return map(_capture, fun); }),
    );
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    return new Unbalanced(
      sizes,
      $vector.map(children, (_capture) => { return map(_capture, fun); }),
    );
  } else {
    let children = node.children;
    return new Leaf($vector.map(children, fun));
  }
}

export function try_map(node, fun) {
  if (node instanceof Balanced) {
    let size$1 = node.size;
    let children = node.children;
    let $ = $vector.try_map(
      children,
      (_capture) => { return try_map(_capture, fun); },
    );
    if ($ instanceof Ok) {
      let children$1 = $[0];
      return new Ok(new Balanced(size$1, children$1));
    } else {
      return $;
    }
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    let $ = $vector.try_map(
      children,
      (_capture) => { return try_map(_capture, fun); },
    );
    if ($ instanceof Ok) {
      let children$1 = $[0];
      return new Ok(new Unbalanced(sizes, children$1));
    } else {
      return $;
    }
  } else {
    let children = node.children;
    let $ = $vector.try_map(children, fun);
    if ($ instanceof Ok) {
      let children$1 = $[0];
      return new Ok(new Leaf(children$1));
    } else {
      return $;
    }
  }
}

export function fold(node, state, fun) {
  if (node instanceof Balanced) {
    let children = node.children;
    return $vector.fold(
      children,
      state,
      (state, node) => { return fold(node, state, fun); },
    );
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return $vector.fold(
      children,
      state,
      (state, node) => { return fold(node, state, fun); },
    );
  } else {
    let children = node.children;
    return $vector.fold(children, state, fun);
  }
}

export function fold_right(node, state, fun) {
  if (node instanceof Balanced) {
    let children = node.children;
    return $vector.fold_right(
      children,
      state,
      (state, node) => { return fold_right(node, state, fun); },
    );
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return $vector.fold_right(
      children,
      state,
      (state, node) => { return fold_right(node, state, fun); },
    );
  } else {
    let children = node.children;
    return $vector.fold_right(children, state, fun);
  }
}

function do_try_fold(node, state, fun) {
  if (node instanceof Balanced) {
    let children = node.children;
    return $vector.try_fold(
      children,
      state,
      (state, child) => { return do_try_fold(child, state, fun); },
    );
  } else if (node instanceof Unbalanced) {
    let children = node.children;
    return $vector.try_fold(
      children,
      state,
      (state, child) => { return do_try_fold(child, state, fun); },
    );
  } else {
    let children = node.children;
    return $vector.fold(children, new Ok(state), fun);
  }
}

export function try_fold(node, state, fun) {
  return do_try_fold(
    node,
    state,
    (state, item) => {
      if (state instanceof Ok) {
        let state$1 = state[0];
        return fun(state$1, item);
      } else {
        return state;
      }
    },
  );
}

export function balanced(shift, nodes) {
  let len = $vector.length(nodes);
  let last_child = $vector.get(len, nodes);
  let max_size = bitwise_shift_left(1, shift);
  let size$1 = max_size * (len - 1) + size(last_child);
  return new Balanced(size$1, nodes);
}

export function unbalanced(shift, children, sizes) {
  let $ = $vector.length(children);
  if ($ === 1) {
    return balanced(shift, children);
  } else {
    return new Unbalanced(sizes, children);
  }
}

export function branch(shift, nodes) {
  let len = $vector.length(nodes);
  let max_size = bitwise_shift_left(1, shift);
  let sizes = compute_sizes(nodes);
  let _block;
  if (len === 1) {
    _block = 0;
  } else {
    _block = $vector.get(len - 1, sizes);
  }
  let prefix_size = _block;
  let is_balanced = prefix_size === max_size * (len - 1);
  if (is_balanced) {
    let size$1 = $vector.get(len, sizes);
    return new Balanced(size$1, nodes);
  } else {
    return new Unbalanced(sizes, nodes);
  }
}

export function get(loop$node, loop$shift, loop$index) {
  while (true) {
    let node = loop$node;
    let shift = loop$shift;
    let index = loop$index;
    if (node instanceof Balanced) {
      let children = node.children;
      let node_index = bitwise_shift_right(index, shift);
      let index$1 = index - bitwise_shift_left(node_index, shift);
      let child = $vector.get(node_index + 1, children);
      loop$node = child;
      loop$shift = shift - branch_bits;
      loop$index = index$1;
    } else if (node instanceof Unbalanced) {
      let sizes = node.sizes;
      let children = node.children;
      let start_search_index = bitwise_shift_right(index, shift);
      let node_index = find_size(sizes, start_search_index + 1, index);
      let _block;
      if (node_index === 0) {
        _block = index;
      } else {
        _block = index - $vector.get(node_index, sizes);
      }
      let index$1 = _block;
      let child = $vector.get(node_index + 1, children);
      loop$node = child;
      loop$shift = shift - branch_bits;
      loop$index = index$1;
    } else {
      let children = node.children;
      return $vector.get(index + 1, children);
    }
  }
}

export function find_index(shift, offset, node, fun) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let children = node.children;
    let child_size = bitwise_shift_left(1, shift);
    return $vector.find_index(
      children,
      (child, index) => {
        let offset$1 = offset + (index - 1) * child_size;
        return find_index(child_shift, offset$1, child, fun);
      },
    );
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    return $vector.find_index(
      children,
      (child, index) => {
        let _block;
        if (index === 1) {
          _block = 0;
        } else {
          _block = $vector.get(index - 1, sizes);
        }
        let child_offset = _block;
        return find_index(child_shift, offset + child_offset, child, fun);
      },
    );
  } else {
    let children = node.children;
    return $vector.find_index(
      children,
      (item, index) => {
        let $ = fun(item);
        if ($) {
          return new Ok((offset + index) - 1);
        } else {
          return $constants.error_nil;
        }
      },
    );
  }
}

export function find_last_index(shift, offset, node, fun) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let children = node.children;
    let child_size = bitwise_shift_left(1, shift);
    return $vector.find_last_index(
      children,
      (child, index) => {
        let offset$1 = offset + (index - 1) * child_size;
        return find_last_index(child_shift, offset$1, child, fun);
      },
    );
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    return $vector.find_last_index(
      children,
      (child, index) => {
        let _block;
        if (index === 1) {
          _block = 0;
        } else {
          _block = $vector.get(index - 1, sizes);
        }
        let child_offset = _block;
        return find_last_index(child_shift, offset + child_offset, child, fun);
      },
    );
  } else {
    let children = node.children;
    return $vector.find_last_index(
      children,
      (item, index) => {
        let $ = fun(item);
        if ($) {
          return new Ok((offset + index) - 1);
        } else {
          return $constants.error_nil;
        }
      },
    );
  }
}

export function update(shift, node, index, fun) {
  if (node instanceof Balanced) {
    let size$1 = node.size;
    let children = node.children;
    let node_index = bitwise_shift_right(index, shift);
    let index$1 = index - bitwise_shift_left(node_index, shift);
    let _block;
    let _pipe = $vector.get(node_index + 1, children);
    let _pipe$1 = ((_capture) => {
      return update(shift - branch_bits, _capture, index$1, fun);
    })(_pipe);
    _block = ((_capture) => {
      return $vector.set(node_index + 1, children, _capture);
    })(_pipe$1);
    let new_children = _block;
    return new Balanced(size$1, new_children);
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    let start_search_index = bitwise_shift_right(index, shift);
    let node_index = find_size(sizes, start_search_index + 1, index);
    let _block;
    if (node_index === 0) {
      _block = index;
    } else {
      _block = index - $vector.get(node_index, sizes);
    }
    let index$1 = _block;
    let _block$1;
    let _pipe = $vector.get(node_index + 1, children);
    let _pipe$1 = ((_capture) => {
      return update(shift - branch_bits, _capture, index$1, fun);
    })(_pipe);
    _block$1 = ((_capture) => {
      return $vector.set(node_index + 1, children, _capture);
    })(_pipe$1);
    let new_children = _block$1;
    return new Unbalanced(sizes, new_children);
  } else {
    let children = node.children;
    let new_children = $vector.set(
      index + 1,
      children,
      fun($vector.get(index + 1, children)),
    );
    return new Leaf(new_children);
  }
}

export function split(shift, node, index) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let children = node.children;
    let node_index = bitwise_shift_right(index, shift);
    let index$1 = index - bitwise_shift_left(node_index, shift);
    let child = $vector.get(node_index + 1, children);
    let $ = split(child_shift, child, index$1);
    if ($ instanceof Split) {
      let prefix = $.prefix;
      let prefix_shift = $.prefix_shift;
      let suffix = $.suffix;
      let suffix_shift = $.suffix_shift;
      let $1 = $vector.split(node_index + 1, children);
      let before_children;
      let after_children;
      before_children = $1[0];
      after_children = $1[1];
      let before_children_len = $vector.length(before_children);
      let _block;
      if (before_children_len === 0) {
        _block = prefix;
      } else {
        _block = balanced(shift, $vector.append(before_children, prefix));
      }
      let prefix$1 = _block;
      let _block$1;
      if (before_children_len === 0) {
        _block$1 = prefix_shift;
      } else {
        _block$1 = shift;
      }
      let prefix_shift$1 = _block$1;
      let after_children_len = $vector.length(after_children);
      let _block$2;
      if (after_children_len === 1) {
        _block$2 = suffix;
      } else {
        _block$2 = branch(shift, $vector.set(1, after_children, suffix));
      }
      let suffix$1 = _block$2;
      let _block$3;
      if (after_children_len === 1) {
        _block$3 = suffix_shift;
      } else {
        _block$3 = shift;
      }
      let suffix_shift$1 = _block$3;
      return new Split(prefix$1, prefix_shift$1, suffix$1, suffix_shift$1);
    } else if (node_index === 0) {
      return $;
    } else {
      let $1 = $vector.split(node_index + 1, children);
      let before_children;
      let after_children;
      before_children = $1[0];
      after_children = $1[1];
      let prefix = balanced(shift, before_children);
      let after_children_len = $vector.length(after_children);
      let _block;
      if (after_children_len === 1) {
        _block = $vector.get(1, after_children);
      } else {
        _block = balanced(shift, after_children);
      }
      let suffix = _block;
      let _block$1;
      if (after_children_len === 1) {
        _block$1 = child_shift;
      } else {
        _block$1 = shift;
      }
      let suffix_shift = _block$1;
      return new Split(prefix, shift, suffix, suffix_shift);
    }
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    let start_search_index = bitwise_shift_right(index, shift);
    let node_index = find_size(sizes, start_search_index + 1, index);
    let _block;
    if (node_index === 0) {
      _block = index;
    } else {
      _block = index - $vector.get(node_index, sizes);
    }
    let index$1 = _block;
    let child = $vector.get(node_index + 1, children);
    let $ = split(child_shift, child, index$1);
    if ($ instanceof Split) {
      let prefix = $.prefix;
      let prefix_shift = $.prefix_shift;
      let suffix = $.suffix;
      let suffix_shift = $.suffix_shift;
      let $1 = $vector.split(node_index + 1, children);
      let before_children;
      let after_children;
      before_children = $1[0];
      after_children = $1[1];
      let $2 = $vector.split(node_index + 1, sizes);
      let before_sizes;
      let after_sizes;
      before_sizes = $2[0];
      after_sizes = $2[1];
      let before_children_len = $vector.length(before_children);
      let _block$1;
      if (before_children_len === 0) {
        _block$1 = prefix;
      } else {
        let children$1 = $vector.append(before_children, prefix);
        let _block$2;
        if (node_index === 0) {
          _block$2 = node_index;
        } else {
          _block$2 = $vector.get(node_index, before_sizes);
        }
        let before_size = _block$2;
        let sizes$1 = $vector.append(before_sizes, before_size + size(prefix));
        _block$1 = unbalanced(shift, children$1, sizes$1);
      }
      let prefix$1 = _block$1;
      let _block$2;
      if (before_children_len === 0) {
        _block$2 = prefix_shift;
      } else {
        _block$2 = shift;
      }
      let prefix_shift$1 = _block$2;
      let after_children_len = $vector.length(after_children);
      let _block$3;
      if (after_children_len === 1) {
        _block$3 = suffix;
      } else {
        let children$1 = $vector.set(1, after_children, suffix);
        let after_delta = size(suffix) - $vector.get(1, after_sizes);
        let sizes$1 = $vector.map_add(after_sizes, after_delta);
        _block$3 = unbalanced(shift, children$1, sizes$1);
      }
      let suffix$1 = _block$3;
      let _block$4;
      if (after_children_len === 1) {
        _block$4 = suffix_shift;
      } else {
        _block$4 = shift;
      }
      let suffix_shift$1 = _block$4;
      return new Split(prefix$1, prefix_shift$1, suffix$1, suffix_shift$1);
    } else if (node_index === 0) {
      return $;
    } else {
      let $1 = $vector.split(node_index + 1, children);
      let before_children;
      let after_children;
      before_children = $1[0];
      after_children = $1[1];
      let $2 = $vector.split(node_index + 1, sizes);
      let before_sizes;
      let after_sizes;
      before_sizes = $2[0];
      after_sizes = $2[1];
      let before_size = $vector.get(node_index, before_sizes);
      let after_sizes$1 = $vector.map_add(after_sizes, - before_size);
      let prefix = unbalanced(shift, before_children, before_sizes);
      let after_children_len = $vector.length(after_children);
      let _block$1;
      if (after_children_len === 1) {
        _block$1 = $vector.get(1, after_children);
      } else {
        _block$1 = unbalanced(shift, after_children, after_sizes$1);
      }
      let suffix = _block$1;
      let _block$2;
      if (after_children_len === 1) {
        _block$2 = child_shift;
      } else {
        _block$2 = shift;
      }
      let suffix_shift = _block$2;
      return new Split(prefix, shift, suffix, suffix_shift);
    }
  } else {
    let children = node.children;
    if (index === 0) {
      return new EmptyPrefix();
    } else {
      let $ = $vector.split(index + 1, children);
      let before;
      let after;
      before = $[0];
      after = $[1];
      let prefix = new Leaf(before);
      let suffix = new Leaf(after);
      return new Split(prefix, 0, suffix, 0);
    }
  }
}

export function index_map(shift, offset, node, fun) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let size$1 = node.size;
    let children = node.children;
    let child_size = bitwise_shift_left(1, shift);
    let children$1 = $vector.index_map(
      children,
      (child, index) => {
        let offset$1 = offset + (index - 1) * child_size;
        return index_map(child_shift, offset$1, child, fun);
      },
    );
    return new Balanced(size$1, children$1);
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    let children$1 = $vector.index_map(
      children,
      (child, index) => {
        let _block;
        if (index === 1) {
          _block = 0;
        } else {
          _block = $vector.get(index - 1, sizes);
        }
        let child_offset = _block;
        return index_map(child_shift, offset + child_offset, child, fun);
      },
    );
    return new Unbalanced(sizes, children$1);
  } else {
    let children = node.children;
    let children$1 = $vector.index_map(
      children,
      (item, index) => { return fun(item, (index + offset) - 1); },
    );
    return new Leaf(children$1);
  }
}

export function index_fold(shift, offset, node, state, fun) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let children = node.children;
    let child_size = bitwise_shift_left(1, shift);
    return $vector.index_fold(
      children,
      state,
      (state, child, index) => {
        let offset$1 = offset + (index - 1) * child_size;
        return index_fold(child_shift, offset$1, child, state, fun);
      },
    );
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    return $vector.index_fold(
      children,
      state,
      (state, child, index) => {
        let _block;
        if (index === 1) {
          _block = 0;
        } else {
          _block = $vector.get(index - 1, sizes);
        }
        let child_offset = _block;
        return index_fold(child_shift, offset + child_offset, child, state, fun);
      },
    );
  } else {
    let children = node.children;
    return $vector.index_fold(
      children,
      state,
      (state, item, index) => { return fun(state, item, (offset + index) - 1); },
    );
  }
}

export function index_fold_right(shift, offset, node, state, fun) {
  let child_shift = shift - branch_bits;
  if (node instanceof Balanced) {
    let children = node.children;
    let child_size = bitwise_shift_left(1, shift);
    return $vector.index_fold_right(
      children,
      state,
      (state, child, index) => {
        let offset$1 = offset + (index - 1) * child_size;
        return index_fold_right(child_shift, offset$1, child, state, fun);
      },
    );
  } else if (node instanceof Unbalanced) {
    let sizes = node.sizes;
    let children = node.children;
    return $vector.index_fold_right(
      children,
      state,
      (state, child, index) => {
        let _block;
        if (index === 1) {
          _block = 0;
        } else {
          _block = $vector.get(index - 1, sizes);
        }
        let child_offset = _block;
        return index_fold_right(
          child_shift,
          offset + child_offset,
          child,
          state,
          fun,
        );
      },
    );
  } else {
    let children = node.children;
    return $vector.index_fold_right(
      children,
      state,
      (state, item, index) => { return fun(state, item, (offset + index) - 1); },
    );
  }
}

function rebalance_finalise(state, construct, shift) {
  let _block;
  let $ = state.overflow;
  if ($ instanceof $Empty) {
    _block = state;
  } else {
    let overflow = $;
    let node = construct($vector.concat_all(overflow));
    _block = rebalance_push_subtree(state, node, toList([]), 0);
  }
  let state$1 = _block;
  let subtree_count = $vector.length(state$1.subtrees);
  let n = subtree_count;
  if (n <= 32) {
    return new OneNode(branch(shift + branch_bits, state$1.subtrees));
  } else {
    let $1 = $vector.split(branch_factor + 1, state$1.subtrees);
    let first_subtrees;
    let second_subtrees;
    first_subtrees = $1[0];
    second_subtrees = $1[1];
    let first_root = branch(shift + branch_bits, first_subtrees);
    let second_root = branch(shift + branch_bits, second_subtrees);
    return new TwoNodes(first_root, second_root);
  }
}

function rebalance_push(state, subtree, extract, construct) {
  let subtree_len = length(subtree);
  let total_len = state.overflow_length + subtree_len;
  let $ = total_len <= branch_factor;
  if ($) {
    let $1 = (state.balance <= 0) || (total_len >= (branch_factor - (globalThis.Math.trunc(
      e_max / 2
    ))));
    if ($1) {
      let _block;
      let $2 = state.overflow;
      if ($2 instanceof $Empty) {
        _block = subtree;
      } else {
        let overflow = $2;
        _block = construct(
          $vector.concat_all(listPrepend(extract(subtree), overflow)),
        );
      }
      let subtree$1 = _block;
      return rebalance_push_subtree(state, subtree$1, toList([]), 0);
    } else {
      return rebalance_skip_subtree(state, extract(subtree));
    }
  } else {
    let to_move_len = branch_factor - state.overflow_length;
    let $1 = $vector.split(to_move_len + 1, extract(subtree));
    let to_move;
    let overflow;
    to_move = $1[0];
    overflow = $1[1];
    let overflow_len = $vector.length(overflow);
    let subtree$1 = construct(
      $vector.concat_all(listPrepend(to_move, state.overflow)),
    );
    return rebalance_push_subtree(
      state,
      subtree$1,
      toList([overflow]),
      overflow_len,
    );
  }
}

function do_rebalance(shift, params, extract, construct, balance) {
  let state = new RebalanceState(balance, $vector.new$(), toList([]), 0);
  let push = (state, node) => {
    return rebalance_push(state, node, extract, construct);
  };
  let _block;
  if (params instanceof FromLeft) {
    let left = params.left;
    let merged = params.merged;
    let state$1 = $vector.fold_skip_last(left, state, push);
    let merged_vec = concat_result_to_vector(merged);
    _block = $vector.fold(merged_vec, state$1, push);
  } else if (params instanceof FromRight) {
    let merged = params.merged;
    let right = params.right;
    let merged_vec = concat_result_to_vector(merged);
    let state$1 = $vector.fold(merged_vec, state, push);
    _block = $vector.fold_skip_first(right, state$1, push);
  } else {
    let left = params.left;
    let merged = params.merged;
    let right = params.right;
    let state$1 = $vector.fold_skip_last(left, state, push);
    let merged_vec = concat_result_to_vector(merged);
    let state$2 = $vector.fold(merged_vec, state$1, push);
    _block = $vector.fold_skip_first(right, state$2, push);
  }
  let state$1 = _block;
  return rebalance_finalise(state$1, construct, shift);
}

function rebalance(shift, params) {
  let _block;
  if (params instanceof FromLeft) {
    let left = params.left;
    let merged = params.merged;
    _block = sum_node_children_counts_skip_last(left) + concat_result_children_count(
      merged,
    );
  } else if (params instanceof FromRight) {
    let merged = params.merged;
    let right = params.right;
    _block = concat_result_children_count(merged) + sum_node_children_counts_skip_first(
      right,
    );
  } else {
    let left = params.left;
    let merged = params.merged;
    let right = params.right;
    _block = (sum_node_children_counts_skip_last(left) + concat_result_children_count(
      merged,
    )) + sum_node_children_counts_skip_first(right);
  }
  let s = _block;
  let _block$1;
  if (params instanceof FromLeft) {
    let left = params.left;
    let merged = params.merged;
    _block$1 = ($vector.length(left) + concat_result_node_count(merged)) - 1;
  } else if (params instanceof FromRight) {
    let merged = params.merged;
    let right = params.right;
    _block$1 = (concat_result_node_count(merged) + $vector.length(right)) - 1;
  } else {
    let left = params.left;
    let merged = params.merged;
    let right = params.right;
    _block$1 = ((($vector.length(left) - 1) + concat_result_node_count(merged)) + $vector.length(
      right,
    )) - 1;
  }
  let n = _block$1;
  let n_opt = bitwise_shift_right((s + branch_factor) - 1, branch_bits);
  let balance = (n - n_opt) - e_max;
  let $ = (balance <= 0) && (n <= branch_factor);
  if ($) {
    let _block$2;
    if (params instanceof FromLeft) {
      let left = params.left;
      let merged = params.merged;
      let merged$1 = concat_result_to_vector(merged);
      let $1 = $vector.length(left);
      if ($1 === 1) {
        _block$2 = merged$1;
      } else {
        _block$2 = $vector.concat($vector.drop_last(left), merged$1);
      }
    } else if (params instanceof FromRight) {
      let merged = params.merged;
      let right = params.right;
      let merged$1 = concat_result_to_vector(merged);
      let $1 = $vector.length(right);
      if ($1 === 1) {
        _block$2 = merged$1;
      } else {
        _block$2 = $vector.concat(merged$1, $vector.drop_first(right));
      }
    } else {
      let left = params.left;
      let merged = params.merged;
      let right = params.right;
      let merged$1 = concat_result_to_vector(merged);
      let left_len = $vector.length(left);
      let right_len = $vector.length(right);
      if (left_len === 1) {
        if (right_len === 1) {
          _block$2 = merged$1;
        } else {
          _block$2 = $vector.concat(merged$1, $vector.drop_first(right));
        }
      } else if (right_len === 1) {
        _block$2 = $vector.concat($vector.drop_last(left), merged$1);
      } else {
        let left_prefix = $vector.drop_last(left);
        let right_suffix = $vector.drop_first(right);
        _block$2 = $vector.concat_all(
          toList([right_suffix, merged$1, left_prefix]),
        );
      }
    }
    let combined = _block$2;
    return new OneNode(branch(shift, combined));
  } else {
    let shift$1 = shift - branch_bits;
    let _block$2;
    let $1 = shift$1 > 0;
    if ($1) {
      let construct = (children) => { return branch(shift$1, children); };
      _block$2 = do_rebalance(
        shift$1,
        params,
        extract_children,
        construct,
        balance,
      );
    } else {
      _block$2 = do_rebalance(
        shift$1,
        params,
        extract_items,
        (var0) => { return new Leaf(var0); },
        balance,
      );
    }
    let result = _block$2;
    return result;
  }
}

function direct_append_balanced(
  left_shift,
  left,
  left_children,
  right_shift,
  right
) {
  let left_len = $vector.length(left_children);
  let left_last = $vector.get(left_len, left_children);
  let $ = direct_concat(left_shift - branch_bits, left_last, right_shift, right);
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = $vector.set(left_len, left_children, updated);
    return new Concatenated(balanced(left_shift, children));
  } else if (left_len < 32) {
    let node = $.right;
    let children = $vector.append(left_children, node);
    let $1 = size(left_last) === bitwise_shift_left(1, left_shift);
    if ($1) {
      return new Concatenated(balanced(left_shift, children));
    } else {
      return new Concatenated(branch(left_shift, children));
    }
  } else {
    let node = $.right;
    return new NoFreeSlot(left, balanced(left_shift, $vector.singleton(node)));
  }
}

/**
 * Direct concatenation that tries to insert nodes into free slots without rebalancing.
 * This is efficient for append/prepend operations where one side is dense.
 */
export function direct_concat(left_shift, left, right_shift, right) {
  if (left instanceof Balanced) {
    if (right instanceof Balanced) {
      if (left_shift > right_shift) {
        let cl = left.children;
        return direct_append_balanced(left_shift, left, cl, right_shift, right);
      } else if (right_shift > left_shift) {
        let cr = right.children;
        return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
        if ($) {
          let merged = $vector.concat(cl, cr);
          let left_last = $vector.get($vector.length(cl), cl);
          let $1 = size(left_last) === bitwise_shift_left(1, left_shift);
          if ($1) {
            return new Concatenated(balanced(left_shift, merged));
          } else {
            return new Concatenated(branch(left_shift, merged));
          }
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else if (right instanceof Unbalanced) {
      if (left_shift > right_shift) {
        let cl = left.children;
        return direct_append_balanced(left_shift, left, cl, right_shift, right);
      } else if (right_shift > left_shift) {
        let sr = right.sizes;
        let cr = right.children;
        return direct_prepend_unbalanced(
          left_shift,
          left,
          right_shift,
          right,
          cr,
          sr,
        );
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, $vector.concat(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else {
      let cl = left.children;
      return direct_append_balanced(left_shift, left, cl, right_shift, right);
    }
  } else if (left instanceof Unbalanced) {
    if (right instanceof Balanced) {
      if (left_shift > right_shift) {
        let sizes = left.sizes;
        let cl = left.children;
        return direct_append_unbalanced(
          left_shift,
          left,
          cl,
          sizes,
          right_shift,
          right,
        );
      } else if (right_shift > left_shift) {
        let cr = right.children;
        return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, $vector.concat(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else if (right instanceof Unbalanced) {
      if (left_shift > right_shift) {
        let sizes = left.sizes;
        let cl = left.children;
        return direct_append_unbalanced(
          left_shift,
          left,
          cl,
          sizes,
          right_shift,
          right,
        );
      } else if (right_shift > left_shift) {
        let sr = right.sizes;
        let cr = right.children;
        return direct_prepend_unbalanced(
          left_shift,
          left,
          right_shift,
          right,
          cr,
          sr,
        );
      } else {
        let cl = left.children;
        let cr = right.children;
        let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
        if ($) {
          return new Concatenated(branch(left_shift, $vector.concat(cl, cr)));
        } else {
          return new NoFreeSlot(left, right);
        }
      }
    } else {
      let sizes = left.sizes;
      let cl = left.children;
      return direct_append_unbalanced(
        left_shift,
        left,
        cl,
        sizes,
        right_shift,
        right,
      );
    }
  } else if (right instanceof Balanced) {
    let cr = right.children;
    return direct_prepend_balanced(left_shift, left, right_shift, right, cr);
  } else if (right instanceof Unbalanced) {
    let sr = right.sizes;
    let cr = right.children;
    return direct_prepend_unbalanced(
      left_shift,
      left,
      right_shift,
      right,
      cr,
      sr,
    );
  } else {
    let cl = left.children;
    let cr = right.children;
    let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
    if ($) {
      return new Concatenated(new Leaf($vector.concat(cl, cr)));
    } else {
      return new NoFreeSlot(left, right);
    }
  }
}

function direct_append_unbalanced(
  left_shift,
  left,
  left_children,
  sizes,
  right_shift,
  right
) {
  let left_len = $vector.length(left_children);
  let left_last = $vector.get(left_len, left_children);
  let $ = direct_concat(left_shift - branch_bits, left_last, right_shift, right);
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = $vector.set(left_len, left_children, updated);
    let last_size = $vector.get(left_len, sizes) + size(updated);
    let sizes$1 = $vector.set(left_len, sizes, last_size);
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else if (left_len < 32) {
    let node = $.right;
    let children = $vector.append(left_children, node);
    let sizes$1 = $vector.append(
      sizes,
      $vector.get(left_len, sizes) + size(node),
    );
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else {
    let node = $.right;
    return new NoFreeSlot(left, balanced(left_shift, $vector.singleton(node)));
  }
}

function direct_prepend_balanced(
  left_shift,
  left,
  right_shift,
  right,
  right_children
) {
  let right_len = $vector.length(right_children);
  let right_first = $vector.get(1, right_children);
  let $ = direct_concat(
    left_shift,
    left,
    right_shift - branch_bits,
    right_first,
  );
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = $vector.set(1, right_children, updated);
    return new Concatenated(branch(right_shift, children));
  } else if (right_len < 32) {
    let node = $.left;
    let children = $vector.prepend(right_children, node);
    return new Concatenated(branch(right_shift, children));
  } else {
    let node = $.left;
    return new NoFreeSlot(balanced(right_shift, $vector.singleton(node)), right);
  }
}

function direct_prepend_unbalanced(
  left_shift,
  left,
  right_shift,
  right,
  right_children,
  sizes
) {
  let right_len = $vector.length(right_children);
  let right_first = $vector.get(1, right_children);
  let $ = direct_concat(
    left_shift,
    left,
    right_shift - branch_bits,
    right_first,
  );
  if ($ instanceof Concatenated) {
    let updated = $.merged;
    let children = $vector.set(1, right_children, updated);
    let size_delta = size(updated) - size(right_first);
    let sizes$1 = $vector.map_add(sizes, size_delta);
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else if (right_len < 32) {
    let node = $.left;
    let children = $vector.prepend(right_children, node);
    let node_size = size(node);
    let _block;
    let _pipe = sizes;
    let _pipe$1 = $vector.map_add(_pipe, node_size);
    _block = $vector.prepend(_pipe$1, node_size);
    let sizes$1 = _block;
    return new Concatenated(new Unbalanced(sizes$1, children));
  } else {
    let node = $.left;
    return new NoFreeSlot(balanced(right_shift, $vector.singleton(node)), right);
  }
}

function concat_children(left_shift, left, right_shift, right) {
  let left_down = left_shift - branch_bits;
  let left_len = $vector.length(left);
  let left_init = $vector.get(left_len, left);
  let right_down = right_shift - branch_bits;
  let right_head = $vector.get(1, right);
  let merged = concat(left_init, left_down, right_head, right_down);
  return rebalance(left_shift, new RebalanceMerge(left, merged, right));
}

export function concat(left, left_shift, right, right_shift) {
  if (left instanceof Balanced) {
    if (left_shift > right_shift) {
      let size$1 = left.size;
      let cl = left.children;
      return concat_left_balanced(left_shift, cl, size$1, right_shift, right);
    } else if (right instanceof Balanced) {
      if (right_shift > left_shift) {
        let cr = right.children;
        return concat_right_balanced(left_shift, left, right_shift, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        return concat_children(left_shift, cl, right_shift, cr);
      }
    } else if (right instanceof Unbalanced) {
      if (right_shift > left_shift) {
        let sizes = right.sizes;
        let cr = right.children;
        return concat_right_unbalanced(left_shift, left, right_shift, cr, sizes);
      } else {
        let cl = left.children;
        let cr = right.children;
        return concat_children(left_shift, cl, right_shift, cr);
      }
    } else {
      let size$1 = left.size;
      let cl = left.children;
      return concat_left_balanced(left_shift, cl, size$1, right_shift, right);
    }
  } else if (left instanceof Unbalanced) {
    if (left_shift > right_shift) {
      let sizes = left.sizes;
      let cl = left.children;
      return concat_left_unbalanced(left_shift, cl, sizes, right_shift, right);
    } else if (right instanceof Balanced) {
      if (right_shift > left_shift) {
        let cr = right.children;
        return concat_right_balanced(left_shift, left, right_shift, cr);
      } else {
        let cl = left.children;
        let cr = right.children;
        return concat_children(left_shift, cl, right_shift, cr);
      }
    } else if (right instanceof Unbalanced) {
      if (right_shift > left_shift) {
        let sizes = right.sizes;
        let cr = right.children;
        return concat_right_unbalanced(left_shift, left, right_shift, cr, sizes);
      } else {
        let cl = left.children;
        let cr = right.children;
        return concat_children(left_shift, cl, right_shift, cr);
      }
    } else {
      let sizes = left.sizes;
      let cl = left.children;
      return concat_left_unbalanced(left_shift, cl, sizes, right_shift, right);
    }
  } else if (right instanceof Balanced) {
    if (right_shift > left_shift) {
      let cr = right.children;
      return concat_right_balanced(left_shift, left, right_shift, cr);
    } else {
      let cr = right.children;
      return concat_right_balanced(left_shift, left, right_shift, cr);
    }
  } else if (right instanceof Unbalanced) {
    if (right_shift > left_shift) {
      let sizes = right.sizes;
      let cr = right.children;
      return concat_right_unbalanced(left_shift, left, right_shift, cr, sizes);
    } else {
      let sizes = right.sizes;
      let cr = right.children;
      return concat_right_unbalanced(left_shift, left, right_shift, cr, sizes);
    }
  } else {
    let cl = left.children;
    let cr = right.children;
    let $ = ($vector.length(cl) + $vector.length(cr)) <= branch_factor;
    if ($) {
      return new OneNode(new Leaf($vector.concat(cl, cr)));
    } else {
      return new TwoNodes(left, right);
    }
  }
}

function concat_left_balanced(
  left_shift,
  left_children,
  left_size,
  right_shift,
  right
) {
  let down_shift = left_shift - branch_bits;
  let left_len = $vector.length(left_children);
  let left_last = $vector.get(left_len, left_children);
  let merged = concat(left_last, down_shift, right, right_shift);
  if (merged instanceof OneNode) {
    let node = merged.node;
    let children = $vector.set(left_len, left_children, node);
    let new_size = (left_size - size(left_last)) + size(node);
    return new OneNode(new Balanced(new_size, children));
  } else {
    return rebalance(left_shift, new FromLeft(left_children, merged));
  }
}

function concat_left_unbalanced(
  left_shift,
  left_children,
  left_sizes,
  right_shift,
  right
) {
  let down_shift = left_shift - branch_bits;
  let left_len = $vector.length(left_children);
  let left_last = $vector.get(left_len, left_children);
  let _block;
  if (left_len === 1) {
    _block = 0;
  } else {
    _block = $vector.get(left_len - 1, left_sizes);
  }
  let prefix_size = _block;
  let merged = concat(left_last, down_shift, right, right_shift);
  if (merged instanceof OneNode) {
    let node = merged.node;
    let children = $vector.set(left_len, left_children, node);
    let sizes = $vector.set(left_len, left_sizes, prefix_size + size(node));
    return new OneNode(unbalanced(left_shift, children, sizes));
  } else {
    return rebalance(left_shift, new FromLeft(left_children, merged));
  }
}

function concat_right_balanced(left_shift, left, right_shift, right_children) {
  let down_shift = right_shift - branch_bits;
  let right_head = $vector.get(1, right_children);
  let merged = concat(left, left_shift, right_head, down_shift);
  if (merged instanceof OneNode) {
    let node = merged.node;
    let children = $vector.set(1, right_children, node);
    return new OneNode(branch(right_shift, children));
  } else {
    return rebalance(right_shift, new FromRight(merged, right_children));
  }
}

function concat_right_unbalanced(
  left_shift,
  left,
  right_shift,
  right_children,
  right_sizes
) {
  let down_shift = right_shift - branch_bits;
  let right_head = $vector.get(1, right_children);
  let merged = concat(left, left_shift, right_head, down_shift);
  if (merged instanceof OneNode) {
    let node = merged.node;
    let children = $vector.set(1, right_children, node);
    let size_delta = size(node) - size(right_head);
    let sizes = $vector.map_add(right_sizes, size_delta);
    return new OneNode(unbalanced(right_shift, children, sizes));
  } else {
    return rebalance(right_shift, new FromRight(merged, right_children));
  }
}
