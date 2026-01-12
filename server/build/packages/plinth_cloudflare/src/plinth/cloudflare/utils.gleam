import gleam/json
import gleam/list

pub fn sparse(entries: List(#(String, json.Json))) -> json.Json {
  list.filter(entries, fn(entry) {
    let #(_, v) = entry
    v != json.null()
  })
  |> json.object
}
