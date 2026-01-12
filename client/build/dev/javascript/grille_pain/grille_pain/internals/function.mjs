export function tap(a, next) {
  next(a);
  return a;
}
