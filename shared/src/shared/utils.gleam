import gleam/bool
import gleam/dict
import gleam/list
import gleam/result

pub fn all_dict_values_contain_errors(
  dict: dict.Dict(_, List(Result(_, _))),
) -> Bool {
  use <- bool.guard(dict.is_empty(dict), return: False)
  dict.fold(dict, True, fn(acc, _, result) {
    // Empty lists should return False (no errors to check)
    case result {
      [] -> False && acc
      _ -> list.all(result, result.is_error) && acc
    }
  })
}
