import {
  List$isEmpty,
  List$NonEmpty$first,
  List$NonEmpty$rest,
} from "./gleam.mjs";

export const empty = () => [];
export const singleton = (x) => [x];
export const pair = (x, y) => [x, y];
export const append = (xs, x) => [...xs, x];
export const prepend = (xs, x) => [x, ...xs];
export const concat = (xs, ys) => [...xs, ...ys];
export const drop_first = (xs) => xs.slice(1);
export const drop_last = (xs) => xs.slice(0, -1);
export const get1 = (idx, xs) => xs[idx - 1];
export const set1 = (idx, xs, x) => xs.with(idx - 1, x);
export const length = (xs) => xs.length;
export const split1 = (idx, xs) => [xs.slice(0, idx - 1), xs.slice(idx - 1)];
export const map = (xs, f) => xs.map(f);

export const bsl = (a, b) => a << b;
export const bsr = (a, b) => a >> b;

export const vector_length = (xs) => xs.length;
export const vector_fold = (xs, init, f) =>
  xs.reduce((acc, x) => f(acc, x), init);

export const concat_all = (xs) => {
  const chunks = [];
  for (; !List$isEmpty(xs); xs = List$NonEmpty$rest(xs)) {
    chunks.push(List$NonEmpty$first(xs));
  }

  return chunks.reverse().flat();
};
