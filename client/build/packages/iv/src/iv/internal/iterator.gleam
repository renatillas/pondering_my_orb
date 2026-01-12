import gleam/yielder.{type Step, type Yielder}
import iv/internal/node.{type Node, Balanced, Leaf, Unbalanced}
import iv/internal/vector.{type Vector}

/// Iterator is a more efficient way to traverse an array without needing to
/// do an index lookup every time. `fold` et al. should be preferred when only
/// iterating a single array.
type Iterator(item) {
  Iterator(
    path: List(#(Int, Vector(Node(item)))),
    current: Int,
    length: Int,
    items: Vector(item),
  )
}

type PathAdvancement(item) {
  AdvancedPath(
    current: Int,
    nodes: Vector(Node(item)),
    rest: List(#(Int, Vector(Node(item)))),
  )
  ReachedTheEnd
}

pub fn new(node: Node(item)) -> Yielder(item) {
  yielder.unfold(init(node), next)
}

/// Initialises the iterator to point _before_ the first element in a subtree.
fn init(node: Node(item)) {
  do_init(node, [])
}

fn do_init(node: Node(item), path) {
  case node {
    Leaf(children) ->
      Iterator(
        path: path,
        current: 0,
        items: children,
        length: vector.length(children),
      )
    Balanced(children:, ..) | Unbalanced(children:, ..) -> {
      let first = vector.get(1, children)
      do_init(first, [#(1, children), ..path])
    }
  }
}

/// Move the iterator to the next element and return it.
fn next(it: Iterator(item)) -> Step(item, Iterator(item)) {
  let Iterator(path:, current:, items:, length:) = it
  let current = current + 1
  case current <= length {
    True -> yielder.Next(vector.get(current, items), Iterator(..it, current:))
    False ->
      case path {
        // only a single leaf
        [] -> yielder.Done
        [#(current, nodes), ..rest] -> {
          case advance(current, nodes, rest) {
            AdvancedPath(current:, nodes:, rest:) -> {
              case vector.get(current, nodes) {
                Leaf(items) -> {
                  let item = vector.get(1, items)
                  let path = [#(current, nodes), ..rest]
                  let length = vector.length(items)
                  yielder.Next(
                    item,
                    Iterator(path:, current: 1, items:, length:),
                  )
                }
                // this should never happen!
                // the element in nodes should always point to a leaf.
                _ -> yielder.Done
              }
            }

            ReachedTheEnd -> yielder.Done
          }
        }
      }
  }
}

/// move to the next element in the path
fn advance(
  current: Int,
  nodes: Vector(Node(item)),
  rest: List(#(Int, Vector(Node(item)))),
) -> PathAdvancement(item) {
  let current = current + 1
  case current <= vector.length(nodes) {
    True -> AdvancedPath(current:, nodes:, rest:)
    False ->
      case rest {
        // this was the last possible level in the path.
        [] -> ReachedTheEnd
        // we can go deeper and try again!
        [#(current, nodes), ..rest] ->
          case advance(current, nodes, rest) {
            AdvancedPath(current:, nodes:, rest:) -> {
              case vector.get(current, nodes) {
                Balanced(children:, ..) | Unbalanced(children:, ..) -> {
                  let rest = [#(current, nodes), ..rest]
                  AdvancedPath(current: 1, nodes: children, rest:)
                }
                // this should never happen!
                // the elements in the path should always be other branches!
                Leaf(..) -> ReachedTheEnd
              }
            }
            ReachedTheEnd as result -> result
          }
      }
  }
}
