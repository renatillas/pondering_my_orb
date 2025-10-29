import gleam/float
import pondering_my_orb/player

pub type Score {
  Score(
    // Configuration
    survival_points_per_second: Float,
    points_per_enemy_kill: Float,
    streak_multiplier_step: Float,
    max_streak_multiplier: Float,
    streak_upgrade_time: Float,
    // Score
    total_score: Float,
    total_survival_points: Float,
    total_kill_points: Float,
    total_kills: Int,
    current_multiplier: Float,
    // Time tracking
    time_since_taking_damage_reset: Float,
  )
}

pub fn init() -> Score {
  Score(
    survival_points_per_second: 10.0,
    points_per_enemy_kill: 20.0,
    streak_multiplier_step: 0.1,
    max_streak_multiplier: 2.0,
    streak_upgrade_time: 10.0,
    total_score: 0.0,
    total_survival_points: 0.0,
    total_kill_points: 0.0,
    total_kills: 0,
    current_multiplier: 1.0,
    time_since_taking_damage_reset: 0.0,
  )
}

pub fn update(player: player.Player, score: Score, delta_time: Float) -> Score {
  let time_since_taking_damage_reset =
    score.time_since_taking_damage_reset +. delta_time /. 1000.0

  echo time_since_taking_damage_reset

  let #(new_score, new_current_multiplier) = case
    player.time_since_taking_damage >=. score.streak_upgrade_time,
    score.time_since_taking_damage_reset >=. score.streak_upgrade_time
  {
    True, True -> {
      #(
        Score(..score, time_since_taking_damage_reset: 0.0),
        float.min(
          score.current_multiplier +. score.streak_multiplier_step,
          score.max_streak_multiplier,
        ),
      )
    }
    True, False -> #(
      Score(..score, time_since_taking_damage_reset:),
      score.current_multiplier,
    )
    _, _ -> #(Score(..score, time_since_taking_damage_reset:), 1.0)
  }

  let survival_points_earned =
    delta_time /. 1000.0 *. score.survival_points_per_second
  let multiplied_survival_points =
    survival_points_earned *. new_current_multiplier

  let new_total_score = score.total_score +. multiplied_survival_points
  let new_total_survival_points =
    score.total_survival_points +. multiplied_survival_points

  Score(
    ..new_score,
    total_score: new_total_score,
    total_survival_points: new_total_survival_points,
    current_multiplier: new_current_multiplier,
  )
}

pub fn take_damage(score: Score) -> Score {
  Score(..score, time_since_taking_damage_reset: 0.0)
}

pub fn enemy_killed(score: Score) -> Score {
  let kill_points = score.points_per_enemy_kill *. score.current_multiplier
  let new_total_kill_points = score.total_kill_points +. kill_points
  let new_total_kills = score.total_kills + 1
  let new_total_score = score.total_score +. kill_points

  Score(
    ..score,
    total_kill_points: new_total_kill_points,
    total_kills: new_total_kills,
    total_score: new_total_score,
  )
}
