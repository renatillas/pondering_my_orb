# iv

[![Package Version](https://img.shields.io/hexpm/v/iv)](https://hex.pm/packages/iv)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/iv/)

`iv` is a fast, general-purpose, persistent array structure for Gleam.

You can use it like you would use an array in other programming languages and
expect comparable or better runtime characteristics. It offers
_O(log n)_ or effectively constant runtime on all main operations, including
`concat` and `split`, making it an excellent choice when parallelising workloads.


### Benchmarks

`iv` does not try to be the fastest at anything, but offer consistent, high
performance across all types of workloads.

You can find benchmarks [here](./benchmarks.html).

### Installation

```sh
gleam add iv@1
```

### Example: Bubble-Sort

```gleam
import iv
import gleam/int

// bubble sort, in my gleam?
pub fn main() {
  // make an array of 10 random integers
  let array = iv.initialise(10, fn(_) { int.random(100) })
  let sorted = bubble_sort(array)

  use item <- iv.each(sorted)

  io.println(int.to_string(item))
}

fn bubble_sort(array) {
  bubble_sort_loop(array, 1, iv.size(array))
}

fn bubble_sort_loop(array, index, max_index) {
  case iv.get(array, index - 1), iv.get(array, index) {
    // found 2 elements in the wrong order, swap them, then continue
    Ok(prev), Ok(curr) if prev > curr -> {
      let array =
        array
        |> iv.try_set(index, prev)
        |> iv.try_set(index - 1, curr)
      bubble_sort_loop(array, index + 1, max_index)
    }

    // found 2 elements in the correct order, we can skip them!
    Ok(_), Ok(_) if index < max_index ->
      bubble_sort_loop(array, index + 1, max_index)

    // reached the end, decrease max_index then try again!
    _, _ if max_index > 2 -> bubble_sort_loop(array, 1, max_index - 1)

    // reached the end and no more elements to swap, we are done.
    _, _ -> array
  }
}
```

Further documentation can be found at <https://hexdocs.pm/iv>.

### Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam run -m benchmark # Run the benchmarks
```

### Implementation

`iv` is based on the _RRB-Vector_, an advanced immutable data structure based
on Clojures persistent vectors developed by Bagwell and Rompf. If you're
interested in that sort of thing, I highly recommend also checking out L'oranges
masters thesis, which is a very rigorous presentation of the algorithms and
mathematics behind them. The blog post by Horne-Khan implements the main ideas,
but is easier to digest without a strong computer science background.

`iv` improves on the data structure as presented by offering fast appends,
prepends and inserts for arbitrary numbers of elements and improving general
node reconstruction time.

- L’orange, J. N. (2014). Improving RRB-Tree Performance through Transience \
  Available: <https://hypirion.com/thesis.pdf>
- Stucki, N., Rompf, T., Ureche, V., & Bagwell, P. (2015). RRB Vector: a practical general purpose immutable sequence. In Proceedings of the 20th ACM SIGPLAN International Conference on Functional Programming (pp. 342-354). \
  Available: <https://www.cs.purdue.edu/homes/rompf/papers/stucki-icfp15.pdf>
- Bagwell, P., Rompf, T. (2011). RRB-Trees: efficient immutable vectors. \
  Available: <http://infoscience.epfl.ch/record/169879/files/RMTrees.pdf>
- Horne-Khan, P. (2024). Relaxed Radix Balanced Trees. \
  Available: <https://peter.horne-khan.com/relaxed-radix-balanced-trees/>
- konsumlamm (2021). rrb-vector: Efficient RRB-Vectors. \
  Available: <https://github.com/konsumlamm/rrb-vector>
- Hansen, R. H. (2017). Elm array exploration. \
  Available: <https://github.com/robinheghan/elm-array-exploration>
