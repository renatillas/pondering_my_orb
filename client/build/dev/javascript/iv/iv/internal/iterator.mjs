import * as $yielder from "../../../gleam_yielder/gleam/yielder.mjs";
import {
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
} from "../../gleam.mjs";
import * as $node from "../../iv/internal/node.mjs";
import { Balanced, Leaf, Unbalanced } from "../../iv/internal/node.mjs";
import * as $vector from "../../iv/internal/vector.mjs";

class Iterator extends $CustomType {
  constructor(path, current, length, items) {
    super();
    this.path = path;
    this.current = current;
    this.length = length;
    this.items = items;
  }
}

class AdvancedPath extends $CustomType {
  constructor(current, nodes, rest) {
    super();
    this.current = current;
    this.nodes = nodes;
    this.rest = rest;
  }
}

class ReachedTheEnd extends $CustomType {}

function do_init(loop$node, loop$path) {
  while (true) {
    let node = loop$node;
    let path = loop$path;
    if (node instanceof Balanced) {
      let children = node.children;
      let first = $vector.get(1, children);
      loop$node = first;
      loop$path = listPrepend([1, children], path);
    } else if (node instanceof Unbalanced) {
      let children = node.children;
      let first = $vector.get(1, children);
      loop$node = first;
      loop$path = listPrepend([1, children], path);
    } else {
      let children = node.children;
      return new Iterator(path, 0, $vector.length(children), children);
    }
  }
}

/**
 * Initialises the iterator to point _before_ the first element in a subtree.
 * 
 * @ignore
 */
function init(node) {
  return do_init(node, toList([]));
}

/**
 * move to the next element in the path
 * 
 * @ignore
 */
function advance(current, nodes, rest) {
  let current$1 = current + 1;
  let $ = current$1 <= $vector.length(nodes);
  if ($) {
    return new AdvancedPath(current$1, nodes, rest);
  } else {
    if (rest instanceof $Empty) {
      return new ReachedTheEnd();
    } else {
      let rest$1 = rest.tail;
      let current$2 = rest.head[0];
      let nodes$1 = rest.head[1];
      let $1 = advance(current$2, nodes$1, rest$1);
      if ($1 instanceof AdvancedPath) {
        let current$3 = $1.current;
        let nodes$2 = $1.nodes;
        let rest$2 = $1.rest;
        let $2 = $vector.get(current$3, nodes$2);
        if ($2 instanceof Balanced) {
          let children = $2.children;
          let rest$3 = listPrepend([current$3, nodes$2], rest$2);
          return new AdvancedPath(1, children, rest$3);
        } else if ($2 instanceof Unbalanced) {
          let children = $2.children;
          let rest$3 = listPrepend([current$3, nodes$2], rest$2);
          return new AdvancedPath(1, children, rest$3);
        } else {
          return new ReachedTheEnd();
        }
      } else {
        return $1;
      }
    }
  }
}

/**
 * Move the iterator to the next element and return it.
 * 
 * @ignore
 */
function next(it) {
  let path;
  let current;
  let length;
  let items;
  path = it.path;
  current = it.current;
  length = it.length;
  items = it.items;
  let current$1 = current + 1;
  let $ = current$1 <= length;
  if ($) {
    return new $yielder.Next(
      $vector.get(current$1, items),
      new Iterator(it.path, current$1, it.length, it.items),
    );
  } else {
    if (path instanceof $Empty) {
      return new $yielder.Done();
    } else {
      let rest = path.tail;
      let current$2 = path.head[0];
      let nodes = path.head[1];
      let $1 = advance(current$2, nodes, rest);
      if ($1 instanceof AdvancedPath) {
        let current$3 = $1.current;
        let nodes$1 = $1.nodes;
        let rest$1 = $1.rest;
        let $2 = $vector.get(current$3, nodes$1);
        if ($2 instanceof Leaf) {
          let items$1 = $2.children;
          let item = $vector.get(1, items$1);
          let path$1 = listPrepend([current$3, nodes$1], rest$1);
          let length$1 = $vector.length(items$1);
          return new $yielder.Next(
            item,
            new Iterator(path$1, 1, length$1, items$1),
          );
        } else {
          return new $yielder.Done();
        }
      } else {
        return new $yielder.Done();
      }
    }
  }
}

export function new$(node) {
  return $yielder.unfold(init(node), next);
}
