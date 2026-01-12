import { toList } from "../gleam.mjs";
import * as $internal from "../shore/internal.mjs";
import * as $style from "../shore/style.mjs";

/**
 * A Cell is a container item within a Grid which contains a collection of ui items (or another Grid).
 *
 * A Cell can be a single "square" within a Grid, or it can span across multiple "squares" in a Grid.
 *
 * Using the row and col arguments to define the start and end rows and columns
 * respectively that the content should span across (this is a 0-based index).
 *
 * For example, in a Grid made up of four equally sized "squares" defined as
 * ```gleam
 * rows: [style.Pct(50), style.Pct(50)],
 * cols: [style.Pct(50), style.Pct(50)],
 * ```
 * (a.k.a. two rows and two columns at 50% each).
 *
 * Then to position a cell, consider the following examples:
 *
 * * `row: #(0,0), col: #(0,0)` would be the top left
 * * `row: #(0,1), col: #(0,0)` would be the left half
 * * `row: #(0,1), col: #(0,1)` would be the entire grid
 * * `row: #(0,0), col: #(0,1)` would be the top half
 */
export function cell(content, row, col) {
  return new $internal.Cell(content, row, col);
}

/**
 * A grid-based layout defining rows and columns which contain cells and the
 * gaps between them.
 *
 * This should be remeniscent of CSS Grid. You define a list of rows and
 * columns by size, then use Cells to fill the rows/columns to create descrete
 * areas of ui elements.
 *
 * Consider using some of the default provided layouts, such as `center` and
 * `split` or view the examples/layouts for more complex custom layouts.
 *
 * Note: Layouts can be nested as long as it is the only child of a cell.
 */
export function grid(gap, rows, cols, cells) {
  return new $internal.Layouts(new $internal.Grid(gap, rows, cols, cells));
}

/**
 * A layout which centers vertically and horizontally
 */
export function center(content, width, height) {
  let _pipe = new $internal.Grid(
    0,
    toList([new $style.Fill(), height, new $style.Fill()]),
    toList([new $style.Fill(), width, new $style.Fill()]),
    toList([new $internal.Cell(content, [1, 1], [1, 1])]),
  );
  return new $internal.Layouts(_pipe);
}

/**
 * A layout which has a 50/50 split
 */
export function split(left, right) {
  let _pipe = new $internal.Grid(
    0,
    toList([new $style.Pct(100)]),
    toList([new $style.Pct(50), new $style.Fill()]),
    toList([
      new $internal.Cell(left, [0, 0], [0, 0]),
      new $internal.Cell(right, [0, 0], [1, 1]),
    ]),
  );
  return new $internal.Layouts(_pipe);
}
