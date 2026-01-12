import iv/internal/constants
import iv/internal/vector.{type Vector}

@target(erlang)
pub const branch_bits = 4

@target(erlang)
pub const branch_factor = 16

// javascript has very highly optimised arrays and we don't have the code
// explosion problem we have in erlang, so we use a highler branching factor!
// this of course makes concats slower, but everything else faster by ~10-25%

@target(javascript)
pub const branch_bits = 5

@target(javascript)
pub const branch_factor = 32

/// Maximum extra search steps allowed in relaxed nodes.
/// According to Bagwell & Rompf's RRB-Vector research, E=2 provides a good
/// balance between indexing efficiency and concatenation cost.
/// This implements the Search Step Invariant: S ≤ ⌈P/M⌉ + E
/// where S is slots, P is items, M is branch_factor, and E is e_max.
const e_max = 2

/// All branches always have the same height.
/// Balanced/Unbalanced here refers to the distribution of items.
pub type Node(item) {
  /// Balanced sub-trees are left-full.
  Balanced(size: Int, children: Vector(Node(item)))
  /// Unbalanced sub-trees are less-than left-full.
  Unbalanced(sizes: Vector(Int), children: Vector(Node(item)))
  Leaf(children: Vector(item))
}

// -- CONSTRUCTORS -------------------------------------------------------------

pub fn balanced(shift shift: Int, children nodes: Vector(Node(item))) {
  let len = vector.length(nodes)
  let last_child = vector.get(len, nodes)
  // int.bitwise_shift_left(1, shift)
  let max_size = bitwise_shift_left(1, shift)
  let size = max_size * { len - 1 } + size(last_child)
  Balanced(size:, children: nodes)
}

pub fn unbalanced(
  shift shift: Int,
  children children: Vector(Node(item)),
  sizes sizes: Vector(Int),
) {
  case vector.length(children) {
    1 -> balanced(shift, children)
    _ -> Unbalanced(sizes:, children:)
  }
}

pub fn branch(
  shift shift: Int,
  children nodes: Vector(Node(item)),
) -> Node(item) {
  let len = vector.length(nodes)
  // int.bitwise_shift_left(1, shift)
  let max_size = bitwise_shift_left(1, shift)

  let sizes = compute_sizes(nodes)
  let prefix_size = case len {
    1 -> 0
    _ -> vector.get(len - 1, sizes)
  }
  let is_balanced = prefix_size == max_size * { len - 1 }

  case is_balanced {
    True -> {
      let size = vector.get(len, sizes)
      Balanced(children: nodes, size:)
    }
    False -> Unbalanced(sizes:, children: nodes)
  }
}

@external(erlang, "iv_ffi", "compute_sizes")
fn compute_sizes(nodes: Vector(Node(item))) -> Vector(Int) {
  let first_size = size(vector.get(1, nodes))
  use sizes, node <- vector.fold_skip_first(nodes, vector.singleton(first_size))
  let size = vector.get(vector.length(sizes), sizes) + size(node)
  vector.append(sizes, size)
}

/// Size is the number of _individual values_ stored in this node.
pub fn size(node: Node(a)) -> Int {
  case node {
    Balanced(size:, ..) -> size
    Leaf(children) -> vector.length(children)
    Unbalanced(sizes:, ..) -> vector.get(vector.length(sizes), sizes)
  }
}

/// Length is the number of _direct children_ this node has
fn length(node: Node(a)) -> Int {
  case node {
    Balanced(children:, ..) | Unbalanced(children:, ..) ->
      vector.length(children)
    Leaf(children:) -> vector.length(children)
  }
}

// -- QUERY --------------------------------------------------------------------

pub fn get(node: Node(item), shift: Int, index: Int) -> item {
  // inlined node_index manually for performance :(
  case node {
    Balanced(children:, ..) -> {
      let node_index = bitwise_shift_right(index, shift)
      let index = index - bitwise_shift_left(node_index, shift)
      let child = vector.get(node_index + 1, children)
      get(child, shift - branch_bits, index)
    }
    Unbalanced(children:, sizes:) -> {
      let start_search_index = bitwise_shift_right(index, shift)
      let node_index = find_size(sizes, start_search_index + 1, index)
      let index = case node_index {
        0 -> index
        // node_index + 1 - 1
        _ -> index - vector.get(node_index, sizes)
      }
      let child = vector.get(node_index + 1, children)
      get(child, shift - branch_bits, index)
    }
    Leaf(children:) -> vector.get(index + 1, children)
  }
}

fn find_size(sizes, size_idx_plus_one, index) {
  // since trees always have a fixed height and we only allow _fewer_ than
  // node.balanced elements, we always know that the earliest possible slot is
  // the default radix-search based slot (in which case the tree would be
  //  completely full and node.balanced).
  //
  // You should therefore call find_size with an initial size_idx_plus_one
  // of int.bitwise_shift_right(index, shift) + 1
  //
  case vector.get(size_idx_plus_one, sizes) > index {
    True -> size_idx_plus_one - 1
    False -> find_size(sizes, size_idx_plus_one + 1, index)
  }
}

pub fn find_map(node: Node(_), fun) {
  case node {
    Leaf(children) -> vector.find_map(children, fun)
    Balanced(children:, ..) | Unbalanced(children:, ..) ->
      vector.find_map(children, find_map(_, fun))
  }
}

pub fn find_index(shift: Int, offset: Int, node: Node(_), fun) {
  let child_shift = shift - branch_bits

  case node {
    Leaf(children) ->
      vector.find_index(children, fn(item, index) {
        case fun(item) {
          True -> Ok(offset + index - 1)
          False -> constants.error_nil
        }
      })
    Balanced(children:, ..) -> {
      let child_size = bitwise_shift_left(1, shift)
      vector.find_index(children, fn(child, index) {
        let offset = offset + { index - 1 } * child_size
        find_index(child_shift, offset, child, fun)
      })
    }
    Unbalanced(children:, sizes:) ->
      vector.find_index(children, fn(child, index) {
        let child_offset = case index {
          1 -> 0
          _ -> vector.get(index - 1, sizes)
        }
        find_index(child_shift, offset + child_offset, child, fun)
      })
  }
}

pub fn find_last_index(shift: Int, offset: Int, node: Node(_), fun) {
  let child_shift = shift - branch_bits

  case node {
    Leaf(children) ->
      vector.find_last_index(children, fn(item, index) {
        case fun(item) {
          True -> Ok(offset + index - 1)
          False -> constants.error_nil
        }
      })
    Balanced(children:, ..) -> {
      let child_size = bitwise_shift_left(1, shift)
      vector.find_last_index(children, fn(child, index) {
        let offset = offset + { index - 1 } * child_size
        find_last_index(child_shift, offset, child, fun)
      })
    }
    Unbalanced(children:, sizes:) ->
      vector.find_last_index(children, fn(child, index) {
        let child_offset = case index {
          1 -> 0
          _ -> vector.get(index - 1, sizes)
        }
        find_last_index(child_shift, offset + child_offset, child, fun)
      })
  }
}

// -- MANIPULATE ---------------------------------------------------------------

pub fn update(shift, node, index, fun) {
  case node {
    Balanced(children:, size:) -> {
      let node_index = bitwise_shift_right(index, shift)
      let index = index - bitwise_shift_left(node_index, shift)

      let new_children =
        vector.get(node_index + 1, children)
        |> update(shift - branch_bits, _, index, fun)
        |> vector.set(node_index + 1, children, _)

      Balanced(size:, children: new_children)
    }
    Unbalanced(sizes:, children:) -> {
      let start_search_index = bitwise_shift_right(index, shift)
      let node_index = find_size(sizes, start_search_index + 1, index)
      let index = case node_index {
        0 -> index
        // node_index + 1 - 1
        _ -> index - vector.get(node_index, sizes)
      }

      let new_children =
        vector.get(node_index + 1, children)
        |> update(shift - branch_bits, _, index, fun)
        |> vector.set(node_index + 1, children, _)

      Unbalanced(sizes:, children: new_children)
    }
    Leaf(children:) -> {
      let new_children =
        vector.set(index + 1, children, fun(vector.get(index + 1, children)))
      Leaf(new_children)
    }
  }
}

// -- CONCAT -------------------------------------------------------------------

/// Result of concat/rebalance operations.
/// When two nodes are returned, the first is always full (has branch_factor children).
pub type ConcatResult(item) {
  /// Successfully merged into a single node
  OneNode(node: Node(item))
  /// Requires two nodes: first is full, second has remaining children
  TwoNodes(full: Node(item), partial: Node(item))
}

// -- CONCAT -------------------------------------------------------------------

pub fn concat(
  left: Node(a),
  left_shift: Int,
  right: Node(a),
  right_shift: Int,
) -> ConcatResult(a) {
  case left, right {
    // Left tree is taller - append right into left's last slot
    Balanced(children: cl, size:), _ if left_shift > right_shift ->
      concat_left_balanced(left_shift, cl, size, right_shift, right)

    Unbalanced(children: cl, sizes:), _ if left_shift > right_shift ->
      concat_left_unbalanced(left_shift, cl, sizes, right_shift, right)

    // Right tree is taller - prepend left into right's first slot
    _, Balanced(children: cr, size: _) if right_shift > left_shift ->
      concat_right_balanced(left_shift, left, right_shift, cr)

    _, Unbalanced(children: cr, sizes:) if right_shift > left_shift ->
      concat_right_unbalanced(left_shift, left, right_shift, cr, sizes)

    // Left tree with leaf right
    Balanced(children: cl, size:), Leaf(_) ->
      concat_left_balanced(left_shift, cl, size, right_shift, right)

    Unbalanced(children: cl, sizes:), Leaf(_) ->
      concat_left_unbalanced(left_shift, cl, sizes, right_shift, right)

    // Right tree with leaf left
    Leaf(_), Balanced(children: cr, size: _) ->
      concat_right_balanced(left_shift, left, right_shift, cr)

    Leaf(_), Unbalanced(children: cr, sizes:) ->
      concat_right_unbalanced(left_shift, left, right_shift, cr, sizes)

    Balanced(children: cl, ..), Balanced(children: cr, ..)
    | Balanced(children: cl, ..), Unbalanced(children: cr, ..)
    | Unbalanced(children: cl, ..), Balanced(children: cr, ..)
    | Unbalanced(children: cl, ..), Unbalanced(children: cr, ..)
    -> concat_children(left_shift, cl, right_shift, cr)

    Leaf(cl), Leaf(cr) ->
      case vector.length(cl) + vector.length(cr) <= branch_factor {
        // both leaf nodes fit into a single node and we can combine them directly.
        True -> OneNode(Leaf(vector.concat(cl, cr)))
        False -> TwoNodes(full: left, partial: right)
      }
  }
}

fn concat_children(left_shift, left, right_shift, right) {
  let left_down = left_shift - branch_bits
  let left_len = vector.length(left)
  let left_init = vector.get(left_len, left)
  let right_down = right_shift - branch_bits
  let right_head = vector.get(1, right)

  let merged = concat(left_init, left_down, right_head, right_down)

  rebalance(left_shift, RebalanceMerge(left:, merged:, right:))
}

fn concat_left_balanced(
  left_shift,
  left_children,
  left_size,
  right_shift,
  right,
) {
  let down_shift = left_shift - branch_bits
  let left_len = vector.length(left_children)
  let left_last = vector.get(left_len, left_children)

  let merged = concat(left_last, down_shift, right, right_shift)

  case merged {
    // Merged into 1 node - just replace the last slot
    // For balanced nodes: setting last node stays balanced, just update size
    OneNode(node) -> {
      let children = vector.set(left_len, left_children, node)
      let new_size = left_size - size(left_last) + size(node)
      OneNode(Balanced(size: new_size, children:))
    }
    _ -> rebalance(left_shift, FromLeft(left: left_children, merged:))
  }
}

fn concat_left_unbalanced(
  left_shift,
  left_children,
  left_sizes,
  right_shift,
  right,
) {
  let down_shift = left_shift - branch_bits
  let left_len = vector.length(left_children)
  let left_last = vector.get(left_len, left_children)

  let prefix_size = case left_len {
    1 -> 0
    _ -> vector.get(left_len - 1, left_sizes)
  }

  let merged = concat(left_last, down_shift, right, right_shift)

  case merged {
    OneNode(node) -> {
      let children = vector.set(left_len, left_children, node)
      let sizes = vector.set(left_len, left_sizes, prefix_size + size(node))
      OneNode(unbalanced(left_shift, sizes:, children:))
    }
    _ -> rebalance(left_shift, FromLeft(left: left_children, merged:))
  }
}

fn concat_right_balanced(left_shift, left, right_shift, right_children) {
  let down_shift = right_shift - branch_bits
  let right_head = vector.get(1, right_children)
  let merged = concat(left, left_shift, right_head, down_shift)

  case merged {
    // Merged into 1 node - just replace the first slot
    // For balanced nodes: this makes it unbalanced (first slot changed)
    OneNode(node) -> {
      let children = vector.set(1, right_children, node)
      OneNode(branch(right_shift, children))
    }
    _ -> rebalance(right_shift, FromRight(merged:, right: right_children))
  }
}

fn concat_right_unbalanced(
  left_shift,
  left,
  right_shift,
  right_children,
  right_sizes,
) {
  let down_shift = right_shift - branch_bits
  let right_head = vector.get(1, right_children)
  let merged = concat(left, left_shift, right_head, down_shift)

  case merged {
    // Merged into 1 node - just replace the first slot
    // For unbalanced nodes: need to adjust all sizes by the delta
    OneNode(node) -> {
      let children = vector.set(1, right_children, node)
      let size_delta = size(node) - size(right_head)
      let sizes = vector.map_add(right_sizes, size_delta)
      OneNode(unbalanced(right_shift, sizes:, children:))
    }
    _ -> rebalance(right_shift, FromRight(merged:, right: right_children))
  }
}

type RebalanceState(item, child) {
  RebalanceState(
    balance: Int,
    // Can grow beyond branch_factor - we'll split into 2 roots at the end if needed
    subtrees: Vector(Node(item)),
    overflow: List(Vector(child)),
    overflow_length: Int,
  )
}

type RebalanceParams(item) {
  /// Left tree with merged result from recursive concat.
  FromLeft(left: Vector(Node(item)), merged: ConcatResult(item))
  /// Right tree with merged result from recursive concat.
  FromRight(merged: ConcatResult(item), right: Vector(Node(item)))
  /// Equal height merge with three parts.
  RebalanceMerge(
    left: Vector(Node(item)),
    merged: ConcatResult(item),
    right: Vector(Node(item)),
  )
}

fn concat_result_to_vector(result: ConcatResult(item)) -> Vector(Node(item)) {
  case result {
    OneNode(node) -> vector.singleton(node)
    TwoNodes(full:, partial:) -> vector.pair(full, partial)
  }
}

fn concat_result_children_count(result: ConcatResult(item)) -> Int {
  case result {
    OneNode(node) -> sum_children_counts(0, node)
    TwoNodes(full:, partial:) ->
      sum_children_counts(sum_children_counts(0, full), partial)
  }
}

fn concat_result_node_count(result: ConcatResult(item)) -> Int {
  case result {
    OneNode(..) -> 1
    TwoNodes(..) -> 2
  }
}

fn rebalance(shift: Int, params: RebalanceParams(item)) -> ConcatResult(item) {
  // Check Search Step Invariant: can we skip rebalancing?

  // s is the number of child nodes in the expansion.
  let s = case params {
    FromLeft(left:, merged:) ->
      sum_node_children_counts_skip_last(left)
      + concat_result_children_count(merged)

    FromRight(merged:, right:) ->
      concat_result_children_count(merged)
      + sum_node_children_counts_skip_first(right)

    RebalanceMerge(left:, merged:, right:) ->
      sum_node_children_counts_skip_last(left)
      + concat_result_children_count(merged)
      + sum_node_children_counts_skip_first(right)
  }

  // n is the number of slots we'd currently occupy if we didn't rebalance.
  let n = case params {
    FromLeft(left:, merged:) ->
      vector.length(left) + concat_result_node_count(merged) - 1
    FromRight(merged:, right:) ->
      concat_result_node_count(merged) + vector.length(right) - 1
    RebalanceMerge(left:, merged:, right:) ->
      vector.length(left)
      - 1
      + concat_result_node_count(merged)
      + vector.length(right)
      - 1
  }

  // n_opt is the minimum number of slots we'd need for this amount of child nodes.
  let n_opt = bitwise_shift_right(s + branch_factor - 1, branch_bits)

  // balance = n - n_opt - e_max, so balance <= 0 means n <= n_opt + e_max
  let balance = n - n_opt - e_max

  case balance <= 0 && n <= branch_factor {
    True -> {
      // Can skip rebalancing - just combine the vectors
      let combined = case params {
        FromLeft(left:, merged:) -> {
          let merged = concat_result_to_vector(merged)
          case vector.length(left) {
            1 -> merged
            _ -> vector.concat(vector.drop_last(left), merged)
          }
        }
        FromRight(merged:, right:) -> {
          let merged = concat_result_to_vector(merged)
          case vector.length(right) {
            1 -> merged
            _ -> vector.concat(merged, vector.drop_first(right))
          }
        }
        RebalanceMerge(left:, merged:, right:) -> {
          let merged = concat_result_to_vector(merged)
          let left_len = vector.length(left)
          let right_len = vector.length(right)
          case left_len, right_len {
            1, 1 -> merged
            1, _ -> vector.concat(merged, vector.drop_first(right))
            _, 1 -> vector.concat(vector.drop_last(left), merged)

            _, _ -> {
              let left_prefix = vector.drop_last(left)
              let right_suffix = vector.drop_first(right)
              vector.concat_all([right_suffix, merged, left_prefix])
            }
          }
        }
      }

      OneNode(branch(shift, combined))
    }
    False -> {
      let shift = shift - branch_bits

      // I actively hate this with a passion.
      // Alas, the types are different and I'm not going to copy-paste a 300 lines
      // monstrosity.
      let result = case shift > 0 {
        True -> {
          let construct = fn(children) {
            // io.debug(#("construct", shift, children))
            branch(shift, children)
          }
          do_rebalance(shift, params, extract_children, construct, balance)
        }
        False -> do_rebalance(shift, params, extract_items, Leaf, balance)
      }

      result
    }
  }
}

fn sum_children_counts(count, node) {
  case node {
    Balanced(children:, ..) -> count + vector.length(children)
    Leaf(children) -> count + vector.length(children)
    Unbalanced(children:, ..) -> count + vector.length(children)
  }
}

@external(erlang, "iv_ffi", "sum_node_children_counts_skip_first")
fn sum_node_children_counts_skip_first(nodes: vector.Vector(Node(item))) -> Int {
  vector.fold_skip_first(nodes, 0, sum_children_counts)
}

@external(erlang, "iv_ffi", "sum_node_children_counts_skip_last")
fn sum_node_children_counts_skip_last(nodes: vector.Vector(Node(item))) -> Int {
  vector.fold_skip_last(nodes, 0, sum_children_counts)
}

fn extract_children(node) {
  // unfortunately, we cannot write the rebalancer in a way that works without
  // asserting here.
  // technically we do not care about the type of the items, but we cannot say
  // something like `forall`, so the only other alternative would be to copy
  // the entire thing twice over.
  // instead, I test for the shift value at the top level and then pick the
  // right extract function that will work...
  case node {
    Balanced(children:, ..) | Unbalanced(children:, ..) -> children
    Leaf(_) -> panic
  }
}

fn extract_items(node) {
  let assert Leaf(children) = node
  children
}

fn do_rebalance(shift, params, extract, construct, balance) {
  let state =
    RebalanceState(
      balance:,
      subtrees: vector.new(),
      overflow: [],
      overflow_length: 0,
    )

  let push = fn(state, node) { rebalance_push(state, node, extract, construct) }

  let state = case params {
    FromLeft(left:, merged:) -> {
      let state = vector.fold_skip_last(left, state, push)
      let merged_vec = concat_result_to_vector(merged)
      vector.fold(merged_vec, state, push)
    }

    FromRight(merged:, right:) -> {
      let merged_vec = concat_result_to_vector(merged)
      let state = vector.fold(merged_vec, state, push)
      vector.fold_skip_first(right, state, push)
    }

    RebalanceMerge(left:, merged:, right:) -> {
      let state = vector.fold_skip_last(left, state, push)
      let merged_vec = concat_result_to_vector(merged)
      let state = vector.fold(merged_vec, state, push)
      vector.fold_skip_first(right, state, push)
    }
  }

  rebalance_finalise(state, construct, shift)
}

// subtree needs to be a node.balanced or node.unbalanced node
// - we have 0 < n <= 2*branch_factor subtrees
// - so up to 2*branch_factor^2 children in total
fn rebalance_push(
  state: RebalanceState(item, child),
  subtree: Node(item),
  extract: fn(Node(item)) -> Vector(child),
  construct: fn(Vector(child)) -> Node(item),
) -> RebalanceState(item, child) {
  let subtree_len = length(subtree)
  let total_len = state.overflow_length + subtree_len

  // we do have overflow, so we have to for sure add it first to the current node.
  case total_len <= branch_factor {
    // it fits into  a single node
    True ->
      // are we allowed to push this node with the overflow as a single node?
      // we can do this if either the balance is already satisfied,
      // or the node would be big enough.
      case state.balance <= 0 || total_len >= branch_factor - e_max / 2 {
        True -> {
          let subtree = case state.overflow {
            [] -> subtree
            overflow ->
              construct(vector.concat_all([extract(subtree), ..overflow]))
          }

          rebalance_push_subtree(state, subtree, [], 0)
        }

        // it is not big enough and we are not balanced yet, push more overflow
        False -> rebalance_skip_subtree(state, extract(subtree))
      }

    // it doesn't fit into a single node (this implies we have overflow),
    // so we have to redistribute our overflow into a full node and new overflow.
    False -> {
      // how many items are missing until the node is full?
      let to_move_len = branch_factor - state.overflow_length
      let #(to_move, overflow) = vector.split(to_move_len + 1, extract(subtree))
      let overflow_len = vector.length(overflow)
      let subtree = construct(vector.concat_all([to_move, ..state.overflow]))
      rebalance_push_subtree(state, subtree, [overflow], overflow_len)
    }
  }
}

fn rebalance_skip_subtree(
  state: RebalanceState(item, child),
  children: Vector(child),
) {
  RebalanceState(
    ..state,
    balance: state.balance - 1,
    overflow: [children, ..state.overflow],
    overflow_length: vector.length(children) + state.overflow_length,
  )
}

fn rebalance_push_subtree(
  state: RebalanceState(_, _),
  subtree,
  overflow: List(_),
  overflow_length: Int,
) {
  // Just append to subtrees - we'll split at the end if needed
  RebalanceState(
    ..state,
    subtrees: vector.append(state.subtrees, subtree),
    overflow:,
    overflow_length:,
  )
}

fn rebalance_finalise(
  state: RebalanceState(item, child),
  construct: fn(Vector(child)) -> Node(item),
  shift: Int,
) -> ConcatResult(item) {
  // if we have overflow left, we have to push it now.
  let state = case state.overflow {
    [] -> state
    overflow -> {
      let node = construct(vector.concat_all(overflow))
      rebalance_push_subtree(state, node, [], 0)
    }
  }

  // Now we have all subtrees accumulated
  // Split into 1 or 2 roots based on count
  let subtree_count = vector.length(state.subtrees)

  case subtree_count {
    n if n <= branch_factor ->
      OneNode(branch(shift + branch_bits, state.subtrees))

    _ -> {
      // Need to split into 2 roots
      // First root gets exactly branch_factor subtrees (it's full)
      let #(first_subtrees, second_subtrees) =
        vector.split(branch_factor + 1, state.subtrees)
      let first_root = branch(shift + branch_bits, first_subtrees)
      let second_root = branch(shift + branch_bits, second_subtrees)
      TwoNodes(full: first_root, partial: second_root)
    }
  }
}

// -- DIRECT CONCAT ------------------------------------------------------------

/// Result of direct concat operations.
/// When nodes can be merged directly, Concatenated is returned.
/// When there's no free slot, NoFreeSlot returns both nodes unchanged.
pub type DirectConcatResult(item) {
  Concatenated(merged: Node(item))
  NoFreeSlot(left: Node(item), right: Node(item))
}

/// Direct concatenation that tries to insert nodes into free slots without rebalancing.
/// This is efficient for append/prepend operations where one side is dense.
pub fn direct_concat(
  left_shift: Int,
  left: Node(a),
  right_shift: Int,
  right: Node(a),
) -> DirectConcatResult(a) {
  case left, right {
    // Leaf cases are most frequent so moved up
    Balanced(children: cl, ..), Leaf(_) ->
      direct_append_balanced(left_shift, left, cl, right_shift, right)
    Unbalanced(children: cl, sizes:), Leaf(_) ->
      direct_append_unbalanced(left_shift, left, cl, sizes, right_shift, right)

    Leaf(_), Balanced(children: cr, ..) ->
      direct_prepend_balanced(left_shift, left, right_shift, right, cr)
    Leaf(_), Unbalanced(children: cr, sizes: sr) ->
      direct_prepend_unbalanced(left_shift, left, right_shift, right, cr, sr)

    Leaf(cl), Leaf(cr) -> {
      case vector.length(cl) + vector.length(cr) <= branch_factor {
        True -> Concatenated(Leaf(vector.concat(cl, cr)))
        False -> NoFreeSlot(left, right)
      }
    }

    // Append cases
    Balanced(children: cl, ..), _ if left_shift > right_shift ->
      direct_append_balanced(left_shift, left, cl, right_shift, right)

    Unbalanced(children: cl, sizes:), _ if left_shift > right_shift ->
      direct_append_unbalanced(left_shift, left, cl, sizes, right_shift, right)

    // Prepend cases
    _, Balanced(children: cr, ..) if right_shift > left_shift ->
      direct_prepend_balanced(left_shift, left, right_shift, right, cr)

    _, Unbalanced(children: cr, sizes: sr) if right_shift > left_shift ->
      direct_prepend_unbalanced(left_shift, left, right_shift, right, cr, sr)

    // Same height - try to merge if both fit
    Balanced(children: cl, ..), Balanced(children: cr, ..) ->
      case vector.length(cl) + vector.length(cr) <= branch_factor {
        True -> {
          let merged = vector.concat(cl, cr)
          let left_last = vector.get(vector.length(cl), cl)
          case size(left_last) == bitwise_shift_left(1, left_shift) {
            True -> Concatenated(balanced(left_shift, merged))
            False -> Concatenated(branch(left_shift, merged))
          }
        }
        False -> NoFreeSlot(left, right)
      }

    Balanced(children: cl, ..), Unbalanced(children: cr, ..)
    | Unbalanced(children: cl, ..), Balanced(children: cr, ..)
    | Unbalanced(children: cl, ..), Unbalanced(children: cr, ..)
    ->
      // left side node.unbalanced during append - result will always be node.unbalanced.
      // we could special-case node.unbalanced/node.unbalanced to make it faster, but this case never happens in practice!
      case vector.length(cl) + vector.length(cr) <= branch_factor {
        True -> Concatenated(branch(left_shift, vector.concat(cl, cr)))
        False -> NoFreeSlot(left, right)
      }
  }
}

fn direct_append_balanced(
  left_shift: Int,
  left: Node(a),
  left_children: Vector(Node(a)),
  right_shift: Int,
  right: Node(a),
) -> DirectConcatResult(a) {
  let left_len = vector.length(left_children)
  let left_last = vector.get(left_len, left_children)

  case direct_concat(left_shift - branch_bits, left_last, right_shift, right) {
    Concatenated(updated) -> {
      let children = vector.set(left_len, left_children, updated)
      Concatenated(balanced(left_shift, children))
    }
    NoFreeSlot(right: node, ..) if left_len < branch_factor -> {
      // could not merge further down, but can add the node here
      // NOTE: this is weird, but appending to a fully dense node is the likely case!!
      // since usually, people will use this function on indiviual elements,
      // giving us a fully dense tree naturally.
      let children = vector.append(left_children, node)

      // Check if the tree stays balanced after appending
      // It's balanced if all children except the last are full-sized
      case size(left_last) == bitwise_shift_left(1, left_shift) {
        True -> Concatenated(balanced(left_shift, children))
        False -> Concatenated(branch(left_shift, children))
      }
    }
    NoFreeSlot(right: node, ..) ->
      NoFreeSlot(left:, right: balanced(left_shift, vector.singleton(node)))
  }
}

fn direct_append_unbalanced(
  left_shift: Int,
  left: Node(a),
  left_children: Vector(Node(a)),
  sizes: Vector(Int),
  right_shift: Int,
  right: Node(a),
) -> DirectConcatResult(a) {
  let left_len = vector.length(left_children)
  let left_last = vector.get(left_len, left_children)

  case direct_concat(left_shift - branch_bits, left_last, right_shift, right) {
    Concatenated(updated) -> {
      let children = vector.set(left_len, left_children, updated)
      let last_size = vector.get(left_len, sizes) + size(updated)
      let sizes = vector.set(left_len, sizes, last_size)
      Concatenated(Unbalanced(children:, sizes:))
    }
    NoFreeSlot(right: node, ..) if left_len < branch_factor -> {
      // could not merge further down, but can add the node here
      let children = vector.append(left_children, node)
      let sizes = vector.append(sizes, vector.get(left_len, sizes) + size(node))
      Concatenated(Unbalanced(children:, sizes:))
    }
    NoFreeSlot(right: node, ..) ->
      NoFreeSlot(left:, right: balanced(left_shift, vector.singleton(node)))
  }
}

fn direct_prepend_balanced(
  left_shift: Int,
  left: Node(a),
  right_shift: Int,
  right: Node(a),
  right_children: Vector(Node(a)),
) -> DirectConcatResult(a) {
  let right_len = vector.length(right_children)
  let right_first = vector.get(1, right_children)

  case direct_concat(left_shift, left, right_shift - branch_bits, right_first) {
    Concatenated(updated) -> {
      let children = vector.set(1, right_children, updated)
      Concatenated(branch(right_shift, children))
    }
    NoFreeSlot(left: node, ..) if right_len < branch_factor -> {
      let children = vector.prepend(right_children, node)
      Concatenated(branch(right_shift, children))
    }
    NoFreeSlot(left: node, ..) ->
      NoFreeSlot(left: balanced(right_shift, vector.singleton(node)), right:)
  }
}

fn direct_prepend_unbalanced(
  left_shift: Int,
  left: Node(a),
  right_shift: Int,
  right: Node(a),
  right_children: Vector(Node(a)),
  sizes: Vector(Int),
) -> DirectConcatResult(a) {
  let right_len = vector.length(right_children)
  let right_first = vector.get(1, right_children)

  case direct_concat(left_shift, left, right_shift - branch_bits, right_first) {
    Concatenated(updated) -> {
      let children = vector.set(1, right_children, updated)
      let size_delta = size(updated) - size(right_first)
      let sizes = vector.map_add(sizes, size_delta)
      Concatenated(Unbalanced(children:, sizes:))
    }
    NoFreeSlot(left: node, ..) if right_len < branch_factor -> {
      let children = vector.prepend(right_children, node)
      let node_size = size(node)
      let sizes =
        sizes
        |> vector.map_add(node_size)
        |> vector.prepend(node_size)
      Concatenated(Unbalanced(children:, sizes:))
    }
    NoFreeSlot(left: node, ..) ->
      NoFreeSlot(left: balanced(right_shift, vector.singleton(node)), right:)
  }
}

// -- TRANSFORMS ---------------------------------------------------------------

pub type SplitResult(item) {
  Split(
    prefix: Node(item),
    prefix_shift: Int,
    suffix: Node(item),
    suffix_shift: Int,
  )
  EmptyPrefix
}

pub fn split(shift: Int, node: Node(item), index: Int) -> SplitResult(item) {
  let child_shift = shift - branch_bits

  case node {
    Balanced(children:, ..) -> {
      let node_index = bitwise_shift_right(index, shift)
      let index = index - bitwise_shift_left(node_index, shift)

      let child = vector.get(node_index + 1, children)

      case split(child_shift, child, index) {
        EmptyPrefix if node_index == 0 -> EmptyPrefix
        EmptyPrefix -> {
          let #(before_children, after_children) =
            vector.split(node_index + 1, children)

          let prefix = balanced(shift, before_children)

          let after_children_len = vector.length(after_children)
          let suffix = case after_children_len {
            1 -> vector.get(1, after_children)
            _ -> balanced(shift, after_children)
          }
          let suffix_shift = case after_children_len {
            1 -> child_shift
            _ -> shift
          }

          Split(prefix:, prefix_shift: shift, suffix:, suffix_shift:)
        }
        Split(prefix:, prefix_shift:, suffix:, suffix_shift:) -> {
          let #(before_children, after_children) =
            vector.split(node_index + 1, children)

          let before_children_len = vector.length(before_children)
          let prefix = case before_children_len {
            0 -> prefix
            _ -> balanced(shift, vector.append(before_children, prefix))
          }
          let prefix_shift = case before_children_len {
            0 -> prefix_shift
            _ -> shift
          }

          let after_children_len = vector.length(after_children)
          let suffix = case after_children_len {
            1 -> suffix
            _ -> branch(shift, vector.set(1, after_children, suffix))
          }
          let suffix_shift = case after_children_len {
            1 -> suffix_shift
            _ -> shift
          }

          Split(prefix:, prefix_shift:, suffix:, suffix_shift:)
        }
      }
    }
    Unbalanced(children:, sizes:) -> {
      let start_search_index = bitwise_shift_right(index, shift)
      let node_index = find_size(sizes, start_search_index + 1, index)
      let index = case node_index {
        0 -> index
        // node_index - 1 + 1
        _ -> index - vector.get(node_index, sizes)
      }

      let child = vector.get(node_index + 1, children)

      case split(child_shift, child, index) {
        EmptyPrefix if node_index == 0 -> EmptyPrefix
        EmptyPrefix -> {
          let #(before_children, after_children) =
            vector.split(node_index + 1, children)

          let #(before_sizes, after_sizes) = vector.split(node_index + 1, sizes)

          let before_size = vector.get(node_index, before_sizes)
          let after_sizes = vector.map_add(after_sizes, -before_size)

          let prefix =
            unbalanced(shift, children: before_children, sizes: before_sizes)

          let after_children_len = vector.length(after_children)
          let suffix = case after_children_len {
            1 -> vector.get(1, after_children)
            _ -> unbalanced(shift, children: after_children, sizes: after_sizes)
          }
          let suffix_shift = case after_children_len {
            1 -> child_shift
            _ -> shift
          }

          Split(prefix:, prefix_shift: shift, suffix:, suffix_shift:)
        }
        Split(prefix:, prefix_shift:, suffix:, suffix_shift:) -> {
          let #(before_children, after_children) =
            vector.split(node_index + 1, children)
          let #(before_sizes, after_sizes) = vector.split(node_index + 1, sizes)

          let before_children_len = vector.length(before_children)
          let prefix = case before_children_len {
            0 -> prefix
            _ -> {
              let children = vector.append(before_children, prefix)
              let before_size = case node_index {
                0 -> 0
                _ -> vector.get(node_index, before_sizes)
              }
              let sizes =
                vector.append(before_sizes, before_size + size(prefix))
              unbalanced(shift, children:, sizes:)
            }
          }
          let prefix_shift = case before_children_len {
            0 -> prefix_shift
            _ -> shift
          }

          let after_children_len = vector.length(after_children)
          let suffix = case after_children_len {
            1 -> suffix
            _ -> {
              let children = vector.set(1, after_children, suffix)
              let after_delta = size(suffix) - vector.get(1, after_sizes)
              let sizes = vector.map_add(after_sizes, after_delta)
              unbalanced(shift, children:, sizes:)
            }
          }
          let suffix_shift = case after_children_len {
            1 -> suffix_shift
            _ -> shift
          }

          Split(prefix:, prefix_shift:, suffix:, suffix_shift:)
        }
      }
    }
    Leaf(children) ->
      case index {
        0 -> EmptyPrefix
        _ -> {
          let #(before, after) = vector.split(index + 1, children)

          let prefix = Leaf(before)
          let suffix = Leaf(after)
          Split(prefix:, prefix_shift: 0, suffix:, suffix_shift: 0)
        }
      }
  }
}

pub fn map(node: Node(a), fun: fn(a) -> b) -> Node(b) {
  case node {
    Balanced(children:, size:) ->
      Balanced(size:, children: vector.map(children, map(_, fun)))
    Unbalanced(children:, sizes:) ->
      Unbalanced(sizes:, children: vector.map(children, map(_, fun)))
    Leaf(children) -> Leaf(vector.map(children, fun))
  }
}

pub fn index_map(
  shift: Int,
  offset: Int,
  node: Node(a),
  fun: fn(a, Int) -> b,
) -> Node(b) {
  let child_shift = shift - branch_bits

  case node {
    Balanced(children:, size:) -> {
      let child_size = bitwise_shift_left(1, shift)
      let children =
        vector.index_map(children, fn(child, index) {
          let offset = offset + { index - 1 } * child_size
          index_map(child_shift, offset, child, fun)
        })
      Balanced(children:, size:)
    }
    Unbalanced(children:, sizes:) -> {
      let children =
        vector.index_map(children, fn(child, index) {
          let child_offset = case index {
            1 -> 0
            _ -> vector.get(index - 1, sizes)
          }
          index_map(child_shift, offset + child_offset, child, fun)
        })
      Unbalanced(children:, sizes:)
    }
    Leaf(children) -> {
      let children =
        vector.index_map(children, fn(item, index) {
          fun(item, index + offset - 1)
        })
      Leaf(children)
    }
  }
}

pub fn try_map(node: Node(_), fun) {
  case node {
    Balanced(children:, size:) ->
      case vector.try_map(children, try_map(_, fun)) {
        Ok(children) -> Ok(Balanced(children:, size:))
        Error(error) -> Error(error)
      }
    Unbalanced(children:, sizes:) ->
      case vector.try_map(children, try_map(_, fun)) {
        Ok(children) -> Ok(Unbalanced(children:, sizes:))
        Error(error) -> Error(error)
      }
    Leaf(children) ->
      case vector.try_map(children, fun) {
        Ok(children) -> Ok(Leaf(children))
        Error(error) -> Error(error)
      }
  }
}

// -- LOOPING ------------------------------------------------------------------

pub fn fold(node: Node(item), state: b, fun: fn(b, item) -> b) -> b {
  case node {
    Balanced(children:, ..) | Unbalanced(children:, ..) -> {
      use state, node <- vector.fold(children, state)
      fold(node, state, fun)
    }
    Leaf(children) -> vector.fold(children, state, fun)
  }
}

pub fn index_fold(
  shift: Int,
  offset: Int,
  node: Node(item),
  state: state,
  fun: fn(state, item, Int) -> state,
) -> state {
  let child_shift = shift - branch_bits

  case node {
    Balanced(children:, ..) -> {
      let child_size = bitwise_shift_left(1, shift)
      vector.index_fold(children, state, fn(state, child, index) {
        let offset = offset + { index - 1 } * child_size
        index_fold(child_shift, offset, child, state, fun)
      })
    }
    Unbalanced(children:, sizes:) ->
      vector.index_fold(children, state, fn(state, child, index) {
        let child_offset = case index {
          1 -> 0
          _ -> vector.get(index - 1, sizes)
        }
        index_fold(child_shift, offset + child_offset, child, state, fun)
      })
    Leaf(children) ->
      vector.index_fold(children, state, fn(state, item, index) {
        fun(state, item, offset + index - 1)
      })
  }
}

pub fn fold_right(node: Node(item), state, fun) {
  case node {
    Balanced(children:, ..) | Unbalanced(children:, ..) -> {
      use state, node <- vector.fold_right(children, state)
      fold_right(node, state, fun)
    }
    Leaf(children) -> vector.fold_right(children, state, fun)
  }
}

pub fn index_fold_right(
  shift: Int,
  offset: Int,
  node: Node(item),
  state: state,
  fun: fn(state, item, Int) -> state,
) -> state {
  let child_shift = shift - branch_bits

  case node {
    Balanced(children:, ..) -> {
      let child_size = bitwise_shift_left(1, shift)
      vector.index_fold_right(children, state, fn(state, child, index) {
        let offset = offset + { index - 1 } * child_size
        index_fold_right(child_shift, offset, child, state, fun)
      })
    }
    Unbalanced(children:, sizes:) ->
      vector.index_fold_right(children, state, fn(state, child, index) {
        let child_offset = case index {
          1 -> 0
          _ -> vector.get(index - 1, sizes)
        }
        index_fold_right(child_shift, offset + child_offset, child, state, fun)
      })
    Leaf(children) ->
      vector.index_fold_right(children, state, fn(state, item, index) {
        fun(state, item, offset + index - 1)
      })
  }
}

pub fn try_fold(
  node: Node(item),
  state: state,
  fun: fn(state, item) -> Result(state, error),
) -> Result(state, error) {
  use state, item <- do_try_fold(node, state)
  case state {
    Ok(state) -> fun(state, item)
    Error(_) as result -> result
  }
}

fn do_try_fold(
  node: Node(item),
  state: state,
  fun: fn(Result(state, error), item) -> Result(state, error),
) -> Result(state, error) {
  case node {
    Balanced(children:, ..) | Unbalanced(children:, ..) ->
      vector.try_fold(children, state, fn(state, child) {
        do_try_fold(child, state, fun)
      })
    Leaf(children) -> vector.fold(children, Ok(state), fun)
  }
}

// -- FFI ----------------------------------------------------------------------

@external(erlang, "erlang", "bsl")
@external(javascript, "../../iv_ffi.mjs", "bsl")
fn bitwise_shift_left(value: Int, shift_by: Int) -> Int

@external(erlang, "erlang", "bsr")
@external(javascript, "../../iv_ffi.mjs", "bsr")
fn bitwise_shift_right(value: Int, shift_by: Int) -> Int
