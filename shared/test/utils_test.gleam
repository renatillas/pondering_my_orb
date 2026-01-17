import gleam/dict
import shared/utils

pub fn dict_of_results_has_all_errors_test() {
  let input = dict.new()
  assert utils.all_dict_values_contain_errors(input) == False

  let input =
    dict.from_list([
      #(1, []),
    ])
  assert utils.all_dict_values_contain_errors(input) == False

  let input =
    dict.from_list([
      #(Nil, [Error(Nil)]),
    ])
  assert utils.all_dict_values_contain_errors(input) == True

  let input =
    dict.from_list([
      #(Nil, [Ok(Nil)]),
    ])
  assert utils.all_dict_values_contain_errors(input) == False

  let input =
    dict.from_list([
      #(1, [Error(Nil)]),
      #(2, [Ok(Nil)]),
    ])
  assert utils.all_dict_values_contain_errors(input) == False

  let input =
    dict.from_list([
      #(1, [Error(Nil)]),
      #(2, [Error(Nil)]),
    ])
  assert utils.all_dict_values_contain_errors(input) == True
}
