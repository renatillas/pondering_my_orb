import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Msg {
  StartButtonClicked
}

pub fn view() -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-purple-900 via-indigo-900 to-black",
      ),
    ],
    [
      // Title
      html.div([attribute.class("text-center mb-12 pointer-events-auto")], [
        html.h1(
          [
            attribute.class(
              "text-7xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-amber-400 to-orange-500 mb-4",
            ),
            attribute.style("text-shadow", "0 0 30px rgba(251, 191, 36, 0.5)"),
          ],
          [html.text("PONDERING MY ORB")],
        ),
        html.p([attribute.class("text-2xl text-purple-300")], [
          html.text("A Magical Spell-Casting Adventure"),
        ]),
      ]),
      // Start button
      html.button(
        [
          attribute.class(
            "px-12 py-6 text-3xl font-bold bg-gradient-to-r from-amber-500 to-orange-600 text-white rounded-lg shadow-2xl hover:scale-110 transform transition-all duration-200 border-4 border-amber-300 pointer-events-auto cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(StartButtonClicked),
        ],
        [html.text("START GAME")],
      ),
      // Controls info
      html.div(
        [
          attribute.class(
            "absolute bottom-8 left-1/2 transform -translate-x-1/2 text-center text-purple-300 pointer-events-none",
          ),
        ],
        [
          html.p([attribute.class("mb-2")], [html.text("Controls:")]),
          html.p([attribute.class("text-sm")], [
            html.text(
              "WASD - Move | Mouse - Look | ESC - Pause | SPACE - Resume",
            ),
          ]),
        ],
      ),
    ],
  )
}
