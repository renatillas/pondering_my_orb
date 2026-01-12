import {
  Ok,
  Error,
  toList,
  Empty as $Empty,
  prepend as listPrepend,
  CustomType as $CustomType,
} from "../../gleam.mjs";
import * as $node from "../../iv/internal/node.mjs";
import { branch_bits, branch_factor } from "../../iv/internal/node.mjs";
import * as $vector from "../../iv/internal/vector.mjs";

class Builder extends $CustomType {
  constructor(nodes, items, push_node, push_item) {
    super();
    this.nodes = nodes;
    this.items = items;
    this.push_node = push_node;
    this.push_item = push_item;
  }
}

function append_node(nodes, node, shift) {
  if (nodes instanceof $Empty) {
    return toList([$vector.singleton(node)]);
  } else {
    let nodes$1 = nodes.head;
    let rest = nodes.tail;
    let $ = $vector.length(nodes$1) < branch_factor;
    if ($) {
      return listPrepend($vector.append(nodes$1, node), rest);
    } else {
      let shift$1 = shift + branch_bits;
      let new_node = $node.balanced(shift$1, nodes$1);
      return listPrepend(
        $vector.singleton(node),
        append_node(rest, new_node, shift$1),
      );
    }
  }
}

export function new$() {
  return new Builder(toList([]), $vector.new$(), append_node, $vector.append);
}

function prepend_node(nodes, node, shift) {
  if (nodes instanceof $Empty) {
    return toList([$vector.singleton(node)]);
  } else {
    let nodes$1 = nodes.head;
    let rest = nodes.tail;
    let $ = $vector.length(nodes$1) < branch_factor;
    if ($) {
      return listPrepend($vector.prepend(nodes$1, node), rest);
    } else {
      let shift$1 = shift + branch_bits;
      let new_node = $node.balanced(shift$1, nodes$1);
      return listPrepend(
        $vector.singleton(node),
        prepend_node(rest, new_node, shift$1),
      );
    }
  }
}

export function reverse() {
  return new Builder(toList([]), $vector.new$(), prepend_node, $vector.prepend);
}

export function push(builder, item) {
  let nodes;
  let items;
  let push_node;
  let push_item;
  nodes = builder.nodes;
  items = builder.items;
  push_node = builder.push_node;
  push_item = builder.push_item;
  let $ = $vector.length(items) === branch_factor;
  if ($) {
    let leaf = new $node.Leaf(items);
    return new Builder(
      push_node(nodes, leaf, 0),
      $vector.singleton(item),
      push_node,
      push_item,
    );
  } else {
    return new Builder(nodes, push_item(items, item), push_node, push_item);
  }
}

function compress_nodes(loop$nodes, loop$push_node, loop$shift) {
  while (true) {
    let nodes = loop$nodes;
    let push_node = loop$push_node;
    let shift = loop$shift;
    if (nodes instanceof $Empty) {
      return new Error(undefined);
    } else {
      let $ = nodes.tail;
      if ($ instanceof $Empty) {
        let root = nodes.head;
        return new Ok([shift, root]);
      } else {
        let nodes$1 = nodes.head;
        let rest = $;
        let shift$1 = shift + branch_bits;
        let compressed = push_node(
          rest,
          $node.branch(shift$1, nodes$1),
          shift$1,
        );
        loop$nodes = compressed;
        loop$push_node = push_node;
        loop$shift = shift$1;
      }
    }
  }
}

export function build(builder) {
  let nodes;
  let items;
  let push_node;
  nodes = builder.nodes;
  items = builder.items;
  push_node = builder.push_node;
  let items_len = $vector.length(items);
  let _block;
  let $ = items_len > 0;
  if ($) {
    _block = push_node(nodes, new $node.Leaf(items), 0);
  } else {
    _block = nodes;
  }
  let nodes$1 = _block;
  return compress_nodes(nodes$1, push_node, 0);
}
