import gleam/float
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html

pub fn view() -> element.Element(msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-purple-900 via-indigo-900 to-black",
      ),
    ],
    [
      html.div([attribute.class("text-center")], [
        html.h2(
          [
            attribute.class("text-5xl font-bold text-amber-400 mb-8"),
            attribute.style("text-shadow", "0 0 20px rgba(251, 191, 36, 0.5)"),
          ],
          [html.text("Loading...")],
        ),
        // Animated loading indicator
        html.div(
          [attribute.class("flex gap-3 justify-center")],
          list.map([1, 2, 3, 4, 5], fn(i) {
            html.div(
              [
                attribute.class(
                  "w-4 h-4 bg-amber-400 rounded-full animate-pulse",
                ),
                attribute.style(
                  "animation-delay",
                  float.to_string(int.to_float(i) *. 0.2) <> "s",
                ),
              ],
              [],
            )
          }),
        ),
        html.p([attribute.class("mt-8 text-purple-300 text-xl")], [
          html.text("Preparing your magical arsenal..."),
        ]),
      ]),
    ],
  )
}
