import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import pondering_my_orb/spell

pub type Msg(inventory_msg) {
  SpellRewardClicked(spell.Spell)
  DoneWithLevelUp
  InventoryMsg(inventory_msg)
}

pub fn view(
  rewards: List(spell.Spell),
  inventory_section: element.Element(inventory_msg),
) -> element.Element(Msg(inventory_msg)) {
  html.div(
    [
      attribute.class(
        "fixed inset-0 flex items-center justify-center bg-black/70 backdrop-blur-sm pointer-events-auto overflow-y-auto",
      ),
      attribute.style("z-index", "300"),
    ],
    [
      html.div(
        [
          attribute.class(
            "p-8 bg-gradient-to-br from-amber-900/95 to-orange-900/95 border-4 border-yellow-400 rounded-lg shadow-2xl max-w-4xl my-8",
          ),
          attribute.style("image-rendering", "pixelated"),
        ],
        [
          // Title
          html.div([attribute.class("text-center mb-6")], [
            html.h2(
              [
                attribute.class("text-4xl font-bold text-yellow-300 mb-2"),
                attribute.style(
                  "text-shadow",
                  "0 0 20px rgba(251, 191, 36, 0.8)",
                ),
              ],
              [html.text("LEVEL UP!")],
            ),
            html.p([attribute.class("text-xl text-yellow-100")], [
              html.text(case rewards {
                [] -> "Organize your inventory and click DONE"
                _ -> "Choose a spell and organize your inventory"
              }),
            ]),
          ]),
          // Spell options (only show if there are rewards)
          case rewards {
            [] -> html.div([], [])
            _ ->
              html.div(
                [attribute.class("flex gap-6 justify-center mb-8")],
                list.map(rewards, view_spell_reward_card),
              )
          },
          // Inventory management section (passed from parent)
          html.div(
            [
              attribute.class(
                "border-t-4 border-yellow-600/50 pt-6 mb-6 space-y-6",
              ),
            ],
            [element.map(inventory_section, InventoryMsg)],
          ),
          // Done button
          html.div([attribute.class("flex justify-center")], [
            html.button(
              [
                attribute.class(
                  "px-8 py-4 text-2xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-lg shadow-xl hover:scale-105 transform transition-all duration-200 border-4 border-green-400 cursor-pointer",
                ),
                attribute.style("text-shadow", "2px 2px 4px rgba(0,0,0,0.5)"),
                event.on_click(DoneWithLevelUp),
              ],
              [html.text("DONE")],
            ),
          ]),
        ],
      ),
    ],
  )
}

fn view_spell_reward_card(reward_spell: spell.Spell) -> element.Element(Msg(a)) {
  let #(name, sprite_path, description, type_label, type_color) = case
    reward_spell
  {
    spell.DamageSpell(_, dmg_spell) -> #(
      dmg_spell.name,
      dmg_spell.ui_sprite,
      "Damage: "
        <> float.to_string(float.to_precision(dmg_spell.damage, 1))
        <> " | Speed: "
        <> float.to_string(float.to_precision(dmg_spell.projectile_speed, 1)),
      "DAMAGE",
      "bg-red-600 border-red-400",
    )
    spell.ModifierSpell(_, mod_spell) -> {
      let effects =
        [
          case mod_spell.damage_multiplier {
            m if m != 1.0 ->
              option.Some("DMG x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.damage_addition {
            a if a != 0.0 ->
              option.Some("DMG +" <> float.to_string(float.to_precision(a, 1)))
            _ -> option.None
          },
          case mod_spell.projectile_speed_multiplier {
            m if m != 1.0 ->
              option.Some("SPD x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.projectile_size_multiplier {
            m if m != 1.0 ->
              option.Some("SIZE x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
          case mod_spell.projectile_lifetime_multiplier {
            m if m != 1.0 ->
              option.Some("LIFE x" <> float.to_string(float.to_precision(m, 2)))
            _ -> option.None
          },
        ]
        |> list.filter_map(fn(opt) {
          case opt {
            option.Some(s) -> Ok(s)
            option.None -> Error(Nil)
          }
        })

      let description = case effects {
        [] -> "No effects"
        _ ->
          list.fold(effects, "", fn(acc, effect) {
            case acc {
              "" -> effect
              _ -> acc <> " | " <> effect
            }
          })
      }

      #(
        mod_spell.name,
        mod_spell.ui_sprite,
        description,
        "MODIFIER",
        "bg-green-600 border-green-400",
      )
    }
    spell.MulticastSpell(_, multicast_spell) -> {
      let description = case multicast_spell.spell_count {
        spell.Fixed(n) -> "Casts " <> int.to_string(n) <> " spells at once"
        spell.AllRemaining -> "Casts all remaining spells"
      }
      #(
        multicast_spell.name,
        multicast_spell.ui_sprite,
        description,
        "MULTICAST",
        "bg-purple-600 border-purple-400",
      )
    }
  }

  let tooltip_text = spell_tooltip(reward_spell)

  html.button(
    [
      attribute.class(
        "flex flex-col items-center p-6 bg-gray-900/80 border-4 rounded-lg hover:scale-105 hover:bg-gray-800/80 transform transition-all duration-200 cursor-pointer min-w-[200px]",
      ),
      attribute.class(type_color),
      attribute.attribute("title", tooltip_text),
      event.on_click(SpellRewardClicked(reward_spell)),
    ],
    [
      // Type label
      html.div(
        [
          attribute.class(
            "text-xs font-bold text-white px-2 py-1 rounded mb-2 " <> type_color,
          ),
        ],
        [html.text(type_label)],
      ),
      // Sprite image
      html.div(
        [attribute.class("w-16 h-16 mb-3 flex items-center justify-center")],
        [
          html.img([
            attribute.src(sprite_path),
            attribute.class("w-full h-full object-contain"),
            attribute.style("image-rendering", "pixelated"),
          ]),
        ],
      ),
      // Name
      html.div(
        [attribute.class("text-xl font-bold text-white mb-2 text-center")],
        [html.text(name)],
      ),
      // Description
      html.div(
        [attribute.class("text-sm text-gray-300 text-center leading-tight")],
        [html.text(description)],
      ),
    ],
  )
}

fn spell_tooltip(spell_item: spell.Spell) -> String {
  case spell_item {
    spell.DamageSpell(_, damage_spell) -> {
      let stats = [
        damage_spell.name,
        "─────────────",
        "Damage: "
          <> float.to_string(float.to_precision(damage_spell.damage, 1)),
        "Speed: "
          <> float.to_string(float.to_precision(
          damage_spell.projectile_speed,
          1,
        )),
        "Lifetime: "
          <> float.to_string(float.to_precision(
          damage_spell.projectile_lifetime,
          1,
        ))
          <> "s",
        "Size: "
          <> float.to_string(float.to_precision(damage_spell.projectile_size, 1)),
        "Mana: "
          <> float.to_string(float.to_precision(damage_spell.mana_cost, 1)),
      ]

      // Add cast delay if non-zero
      let stats = case damage_spell.cast_delay_addition {
        0.0 -> stats
        delay -> [
          "Cast Delay: +"
            <> float.to_string(float.to_precision(delay, 2))
            <> "s",
          ..stats
        ]
      }

      // Add critical chance if non-zero
      let stats = case damage_spell.critical_chance {
        0.0 -> stats
        crit -> {
          let crit_percent =
            float.to_string(float.to_precision(crit *. 100.0, 1))
          ["Crit Chance: " <> crit_percent <> "%", ..stats]
        }
      }

      // Add spread if non-zero
      let stats = case damage_spell.spread {
        0.0 -> stats
        spread -> [
          "Spread: +" <> float.to_string(float.to_precision(spread, 1)) <> "°",
          ..stats
        ]
      }

      string.join(list.reverse(stats), "\n")
    }
    spell.ModifierSpell(_, modifier_spell) -> {
      let stats = [modifier_spell.name, "─────────────"]

      // Damage
      let stats = case
        modifier_spell.damage_multiplier,
        modifier_spell.damage_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Damage: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 ->
              "Damage: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Damage: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Speed
      let stats = case
        modifier_spell.projectile_speed_multiplier,
        modifier_spell.projectile_speed_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Speed: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 -> "Speed: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Speed: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Lifetime
      let stats = case
        modifier_spell.projectile_lifetime_multiplier,
        modifier_spell.projectile_lifetime_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Lifetime: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "s"
            _, 0.0 ->
              "Lifetime: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Lifetime: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "s, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Size
      let stats = case
        modifier_spell.projectile_size_multiplier,
        modifier_spell.projectile_size_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> "Size: +" <> float.to_string(float.to_precision(add, 1))
            _, 0.0 -> "Size: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Size: +"
              <> float.to_string(float.to_precision(add, 1))
              <> ", x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Cast delay
      let stats = case
        modifier_spell.cast_delay_multiplier,
        modifier_spell.cast_delay_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Cast Delay: +"
              <> float.to_string(float.to_precision(add, 2))
              <> "s"
            _, 0.0 ->
              "Cast Delay: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Cast Delay: +"
              <> float.to_string(float.to_precision(add, 2))
              <> "s, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Critical chance
      let stats = case
        modifier_spell.critical_chance_multiplier,
        modifier_spell.critical_chance_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ -> {
              let percent = float.to_string(float.to_precision(add *. 100.0, 1))
              "Crit Chance: +" <> percent <> "%"
            }
            _, 0.0 ->
              "Crit Chance: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ -> {
              let percent = float.to_string(float.to_precision(add *. 100.0, 1))
              "Crit Chance: +"
              <> percent
              <> "%, x"
              <> float.to_string(float.to_precision(mult, 2))
            }
          }
          [text, ..stats]
        }
      }

      // Spread
      let stats = case
        modifier_spell.spread_multiplier,
        modifier_spell.spread_addition
      {
        1.0, 0.0 -> stats
        mult, add -> {
          let text = case mult, add {
            1.0, _ ->
              "Spread: +" <> float.to_string(float.to_precision(add, 1)) <> "°"
            _, 0.0 ->
              "Spread: x" <> float.to_string(float.to_precision(mult, 2))
            _, _ ->
              "Spread: +"
              <> float.to_string(float.to_precision(add, 1))
              <> "°, x"
              <> float.to_string(float.to_precision(mult, 2))
          }
          [text, ..stats]
        }
      }

      // Mana cost
      let stats = case modifier_spell.mana_cost {
        0.0 -> stats
        cost -> [
          "Mana: " <> float.to_string(float.to_precision(cost, 1)),
          ..stats
        ]
      }

      string.join(list.reverse(stats), "\n")
    }
    spell.MulticastSpell(_, multicast_spell) -> {
      let count_text = case multicast_spell.spell_count {
        spell.Fixed(n) -> "Casts " <> int.to_string(n) <> " spells"
        spell.AllRemaining -> "Casts all remaining spells"
      }

      string.join(
        [
          multicast_spell.name,
          "─────────────",
          count_text,
          "Mana: "
            <> float.to_string(float.to_precision(multicast_spell.mana_cost, 1)),
        ],
        "\n",
      )
    }
  }
}
