import gleam/float
import gleam/int
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event

pub type Msg {
  ResumeGame
  OpenSettings
  CloseSettings
  CameraDistanceChanged(Float)
}

pub fn view(
  is_settings_open: Bool,
  resuming: Bool,
  camera_distance: Float,
) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/70 pointer-events-auto",
      ),
      attribute.style("z-index", "300"),
    ],
    [
      html.div(
        [
          attribute.class(
            "p-12 bg-gradient-to-br from-purple-900/95 to-indigo-900/95 border-4 border-blue-400 rounded-lg shadow-2xl",
          ),
          attribute.style("image-rendering", "pixelated"),
        ],
        case is_settings_open {
          True -> view_settings_menu(camera_distance)
          False -> view_pause_menu_content(resuming)
        },
      ),
    ],
  )
}

fn view_pause_menu_content(resuming: Bool) -> List(element.Element(Msg)) {
  [
    // Title
    html.div([attribute.class("text-center mb-8")], [
      html.h2(
        [
          attribute.class("text-5xl font-bold text-blue-300 mb-4"),
          attribute.style("text-shadow", "0 0 20px rgba(147, 197, 253, 0.8)"),
        ],
        [
          html.text(case resuming {
            True -> "RESUMING..."
            False -> "PAUSED"
          }),
        ],
      ),
      html.p([attribute.class("text-xl text-blue-100")], [
        html.text(case resuming {
          True -> "Resuming game..."
          False -> "Game is paused"
        }),
      ]),
    ]),
    html.div([attribute.class("flex flex-col gap-4 items-center mb-4")], [
      html.button(
        [
          attribute.class(
            "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-purple-400 cursor-pointer min-w-[300px]",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          attribute.disabled(resuming),
          event.on_click(OpenSettings),
        ],
        [html.text("SETTINGS")],
      ),
    ]),
    // Resume button (disabled when resuming)
    html.div([attribute.class("flex flex-col gap-4 items-center")], [
      html.button(
        [
          attribute.class(case resuming {
            True ->
              "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-gray-600 to-gray-700 text-gray-300 rounded-lg shadow-xl border-4 border-gray-500 cursor-not-allowed min-w-[300px] opacity-50"
            False ->
              "px-12 py-4 text-2xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-green-400 cursor-pointer min-w-[300px]"
          }),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          attribute.disabled(resuming),
          event.on_click(ResumeGame),
        ],
        [html.text("RESUME")],
      ),
      html.div([attribute.class("text-sm text-blue-200 mt-4")], [
        html.text(case resuming {
          True -> "Please wait..."
          False -> "Press SPACE to resume"
        }),
      ]),
    ]),
  ]
}

fn view_settings_menu(camera_distance: Float) -> List(element.Element(Msg)) {
  [
    // Title
    html.div([attribute.class("text-center mb-8")], [
      html.h2(
        [
          attribute.class("text-5xl font-bold text-blue-300 mb-4"),
          attribute.style("text-shadow", "0 0 20px rgba(147, 197, 253, 0.8)"),
        ],
        [html.text("SETTINGS")],
      ),
    ]),
    // Camera distance slider
    html.div([attribute.class("mb-6")], [
      html.label([attribute.class("block text-xl text-blue-100 mb-3")], [
        html.text("Camera Distance"),
      ]),
      html.div([attribute.class("flex items-center gap-4")], [
        html.input([
          attribute.type_("range"),
          attribute.min("1.0"),
          attribute.max("15.0"),
          attribute.step("0.5"),
          attribute.value(float.to_string(camera_distance)),
          attribute.class(
            "flex-1 h-3 bg-gray-700 rounded-lg appearance-none cursor-pointer slider",
          ),
          attribute.style("-webkit-appearance", "none"),
          attribute.style("appearance", "none"),
          event.on_input(fn(value) {
            case float.parse(value) {
              Ok(distance) -> CameraDistanceChanged(distance)
              Error(Nil) -> {
                let assert Ok(distance) = int.parse(value)
                CameraDistanceChanged(int.to_float(distance))
              }
            }
          }),
        ]),
        html.span(
          [
            attribute.class(
              "text-lg text-blue-200 font-mono min-w-[60px] text-right",
            ),
          ],
          [html.text(float.to_string(float.to_precision(camera_distance, 1)))],
        ),
      ]),
    ]),
    // Go back button
    html.div([attribute.class("flex justify-center mt-8")], [
      html.button(
        [
          attribute.class(
            "px-8 py-4 text-xl font-bold bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-purple-400 cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(CloseSettings),
        ],
        [html.text("GO BACK")],
      ),
    ]),
  ]
}
