import gleam/float
import gleam/int
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/score

pub type Msg {
  RestartButtonClicked
}

pub fn view(score_stats: score.Score) -> element.Element(Msg) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex flex-col items-center justify-center bg-gradient-to-b from-red-900 via-purple-900 to-black pointer-events-auto",
      ),
    ],
    [
      html.div([attribute.class("text-center mb-12")], [
        html.h1(
          [
            attribute.class(
              "text-8xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-red-500 to-orange-500 mb-6",
            ),
            attribute.style("text-shadow", "0 0 40px rgba(239, 68, 68, 0.5)"),
          ],
          [html.text("GAME OVER")],
        ),
        html.p([attribute.class("text-3xl text-purple-300 mb-8")], [
          html.text("Your journey has ended..."),
        ]),
        // Stats
        html.div(
          [
            attribute.class(
              "bg-black/50 p-8 rounded-lg border-4 border-red-500 mb-8",
            ),
          ],
          [
            html.p([attribute.class("text-2xl text-white mb-2")], [
              html.text("Final Stats"),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total score: "
                <> float.to_string(float.to_precision(
                  score_stats.total_score,
                  2,
                )),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total survival points: "
                <> int.to_string(float.round(score_stats.total_survival_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total kill points: "
                <> int.to_string(float.round(score_stats.total_kill_points)),
              ),
            ]),
            html.p([attribute.class("text-xl text-gray-300")], [
              html.text(
                "Total kills: " <> int.to_string(score_stats.total_kills),
              ),
            ]),
          ],
        ),
      ]),
      // Restart button
      html.button(
        [
          attribute.class(
            "px-12 py-6 text-3xl font-bold bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-lg shadow-2xl hover:scale-110 transform transition-all duration-200 border-4 border-green-300 cursor-pointer",
          ),
          attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
          event.on_click(RestartButtonClicked),
        ],
        [html.text("TRY AGAIN")],
      ),
    ],
  )
}
