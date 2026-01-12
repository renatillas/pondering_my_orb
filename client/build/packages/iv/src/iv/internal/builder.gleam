import iv/internal/node.{type Node, branch_bits, branch_factor}
import iv/internal/vector.{type Vector}

// Builder is a more efficient way to build up the tree.
// it stores the levels of nodes in reverse order, and compresses them into a
// single node of a higher order once a level is filled, avoiding having to
// traverse the array on every append.
pub opaque type Builder(item) {
  Builder(
    nodes: List(Vector(Node(item))),
    items: Vector(item),
    push_node: fn(List(Vector(Node(item))), Node(item), Int) ->
      List(Vector(Node(item))),
    push_item: fn(Vector(item), item) -> Vector(item),
  )
}

pub fn new() -> Builder(item) {
  Builder(
    nodes: [],
    items: vector.new(),
    push_node: append_node,
    push_item: vector.append,
  )
}

pub fn reverse() -> Builder(item) {
  Builder(
    nodes: [],
    items: vector.new(),
    push_node: prepend_node,
    push_item: vector.prepend,
  )
}

fn append_node(nodes, node, shift) {
  case nodes {
    [] -> [vector.singleton(node)]
    [nodes, ..rest] -> {
      case vector.length(nodes) < branch_factor {
        True -> [vector.append(nodes, node), ..rest]
        False -> {
          let shift = shift + branch_bits
          let new_node = node.balanced(shift, nodes)
          [vector.singleton(node), ..append_node(rest, new_node, shift)]
        }
      }
    }
  }
}

fn prepend_node(nodes, node, shift) {
  case nodes {
    [] -> [vector.singleton(node)]
    [nodes, ..rest] -> {
      case vector.length(nodes) < branch_factor {
        True -> [vector.prepend(nodes, node), ..rest]
        False -> {
          let shift = shift + branch_bits
          let new_node = node.balanced(shift, nodes)
          [vector.singleton(node), ..prepend_node(rest, new_node, shift)]
        }
      }
    }
  }
}

pub fn push(builder, item) {
  let Builder(nodes:, items:, push_node:, push_item:) = builder
  case vector.length(items) == branch_factor {
    True -> {
      let leaf = node.Leaf(items)
      Builder(
        push_node:,
        push_item:,
        nodes: push_node(nodes, leaf, 0),
        items: vector.singleton(item),
      )
    }
    False ->
      Builder(nodes:, items: push_item(items, item), push_node:, push_item:)
  }
}

pub fn build(builder: Builder(item)) -> Result(#(Int, Vector(Node(item))), Nil) {
  let Builder(items:, nodes:, push_node:, ..) = builder
  let items_len = vector.length(items)
  let nodes = case items_len > 0 {
    True -> push_node(nodes, node.Leaf(items), 0)
    False -> nodes
  }

  compress_nodes(nodes, push_node, 0)
}

fn compress_nodes(nodes, push_node, shift) {
  case nodes {
    [] -> Error(Nil)
    [root] -> Ok(#(shift, root))
    [nodes, ..rest] -> {
      let shift = shift + branch_bits
      let compressed = push_node(rest, node.branch(shift, nodes), shift)
      compress_nodes(compressed, push_node, shift)
    }
  }
}
