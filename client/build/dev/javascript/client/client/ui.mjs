import * as $float from "../../gleam_stdlib/gleam/float.mjs";
import * as $int from "../../gleam_stdlib/gleam/int.mjs";
import * as $list from "../../gleam_stdlib/gleam/list.mjs";
import * as $option from "../../gleam_stdlib/gleam/option.mjs";
import * as $result from "../../gleam_stdlib/gleam/result.mjs";
import * as $duration from "../../gleam_time/gleam/time/duration.mjs";
import * as $iv from "../../iv/iv.mjs";
import * as $lustre from "../../lustre/lustre.mjs";
import * as $attribute from "../../lustre/lustre/attribute.mjs";
import { class$, style } from "../../lustre/lustre/attribute.mjs";
import * as $effect from "../../lustre/lustre/effect.mjs";
import * as $element from "../../lustre/lustre/element.mjs";
import * as $html from "../../lustre/lustre/element/html.mjs";
import * as $event from "../../lustre/lustre/event.mjs";
import * as $ui from "../../tiramisu/tiramisu/ui.mjs";
import * as $health from "../client/health.mjs";
import * as $spell from "../client/magic_system/spell.mjs";
import * as $wand from "../client/magic_system/wand.mjs";
import { toList, CustomType as $CustomType, divideFloat } from "../gleam.mjs";

export class FromBridge extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$FromBridge = ($0) => new FromBridge($0);
export const Msg$isFromBridge = (value) => value instanceof FromBridge;
export const Msg$FromBridge$0 = (value) => value[0];

export class HoverWand extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$HoverWand = ($0) => new HoverWand($0);
export const Msg$isHoverWand = (value) => value instanceof HoverWand;
export const Msg$HoverWand$0 = (value) => value[0];

/**
 * Hover spell by wand index and slot index
 */
export class HoverSpell extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const Msg$HoverSpell = ($0) => new HoverSpell($0);
export const Msg$isHoverSpell = (value) => value instanceof HoverSpell;
export const Msg$HoverSpell$0 = (value) => value[0];

export class WandInfo extends $CustomType {
  constructor(wand, cast_index) {
    super();
    this.wand = wand;
    this.cast_index = cast_index;
  }
}
export const WandInfo$WandInfo = (wand, cast_index) =>
  new WandInfo(wand, cast_index);
export const WandInfo$isWandInfo = (value) => value instanceof WandInfo;
export const WandInfo$WandInfo$wand = (value) => value.wand;
export const WandInfo$WandInfo$0 = (value) => value.wand;
export const WandInfo$WandInfo$cast_index = (value) => value.cast_index;
export const WandInfo$WandInfo$1 = (value) => value.cast_index;

export class HealthUpdated extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const BridgeMsg$HealthUpdated = ($0) => new HealthUpdated($0);
export const BridgeMsg$isHealthUpdated = (value) =>
  value instanceof HealthUpdated;
export const BridgeMsg$HealthUpdated$0 = (value) => value[0];

export class WandStateUpdated extends $CustomType {
  constructor($0) {
    super();
    this[0] = $0;
  }
}
export const BridgeMsg$WandStateUpdated = ($0) => new WandStateUpdated($0);
export const BridgeMsg$isWandStateUpdated = (value) =>
  value instanceof WandStateUpdated;
export const BridgeMsg$WandStateUpdated$0 = (value) => value[0];

export class ActiveWandChanged extends $CustomType {
  constructor(index, total_wands) {
    super();
    this.index = index;
    this.total_wands = total_wands;
  }
}
export const BridgeMsg$ActiveWandChanged = (index, total_wands) =>
  new ActiveWandChanged(index, total_wands);
export const BridgeMsg$isActiveWandChanged = (value) =>
  value instanceof ActiveWandChanged;
export const BridgeMsg$ActiveWandChanged$index = (value) => value.index;
export const BridgeMsg$ActiveWandChanged$0 = (value) => value.index;
export const BridgeMsg$ActiveWandChanged$total_wands = (value) =>
  value.total_wands;
export const BridgeMsg$ActiveWandChanged$1 = (value) => value.total_wands;

export class EditModeToggled extends $CustomType {
  constructor(is_open, wands) {
    super();
    this.is_open = is_open;
    this.wands = wands;
  }
}
export const BridgeMsg$EditModeToggled = (is_open, wands) =>
  new EditModeToggled(is_open, wands);
export const BridgeMsg$isEditModeToggled = (value) =>
  value instanceof EditModeToggled;
export const BridgeMsg$EditModeToggled$is_open = (value) => value.is_open;
export const BridgeMsg$EditModeToggled$0 = (value) => value.is_open;
export const BridgeMsg$EditModeToggled$wands = (value) => value.wands;
export const BridgeMsg$EditModeToggled$1 = (value) => value.wands;

export class Model extends $CustomType {
  constructor(bridge, health, active_wand, cast_index, active_wand_index, total_wands, edit_mode, all_wands, hovered_wand, hovered_spell) {
    super();
    this.bridge = bridge;
    this.health = health;
    this.active_wand = active_wand;
    this.cast_index = cast_index;
    this.active_wand_index = active_wand_index;
    this.total_wands = total_wands;
    this.edit_mode = edit_mode;
    this.all_wands = all_wands;
    this.hovered_wand = hovered_wand;
    this.hovered_spell = hovered_spell;
  }
}
export const Model$Model = (bridge, health, active_wand, cast_index, active_wand_index, total_wands, edit_mode, all_wands, hovered_wand, hovered_spell) =>
  new Model(bridge,
  health,
  active_wand,
  cast_index,
  active_wand_index,
  total_wands,
  edit_mode,
  all_wands,
  hovered_wand,
  hovered_spell);
export const Model$isModel = (value) => value instanceof Model;
export const Model$Model$bridge = (value) => value.bridge;
export const Model$Model$0 = (value) => value.bridge;
export const Model$Model$health = (value) => value.health;
export const Model$Model$1 = (value) => value.health;
export const Model$Model$active_wand = (value) => value.active_wand;
export const Model$Model$2 = (value) => value.active_wand;
export const Model$Model$cast_index = (value) => value.cast_index;
export const Model$Model$3 = (value) => value.cast_index;
export const Model$Model$active_wand_index = (value) => value.active_wand_index;
export const Model$Model$4 = (value) => value.active_wand_index;
export const Model$Model$total_wands = (value) => value.total_wands;
export const Model$Model$5 = (value) => value.total_wands;
export const Model$Model$edit_mode = (value) => value.edit_mode;
export const Model$Model$6 = (value) => value.edit_mode;
export const Model$Model$all_wands = (value) => value.all_wands;
export const Model$Model$7 = (value) => value.all_wands;
export const Model$Model$hovered_wand = (value) => value.hovered_wand;
export const Model$Model$8 = (value) => value.hovered_wand;
export const Model$Model$hovered_spell = (value) => value.hovered_spell;
export const Model$Model$9 = (value) => value.hovered_spell;

function init(bridge) {
  let model = new Model(
    bridge,
    $health.new$(100.0),
    new $option.None(),
    0,
    0,
    4,
    false,
    toList([]),
    new $option.None(),
    new $option.None(),
  );
  return [
    model,
    $ui.register_lustre(bridge, (var0) => { return new FromBridge(var0); }),
  ];
}

function update(model, msg) {
  if (msg instanceof FromBridge) {
    let $ = msg[0];
    if ($ instanceof HealthUpdated) {
      let new_health = $[0];
      return [
        new Model(
          model.bridge,
          new_health,
          model.active_wand,
          model.cast_index,
          model.active_wand_index,
          model.total_wands,
          model.edit_mode,
          model.all_wands,
          model.hovered_wand,
          model.hovered_spell,
        ),
        $effect.none(),
      ];
    } else if ($ instanceof WandStateUpdated) {
      let wand = $[0].wand;
      let cast_index = $[0].cast_index;
      return [
        new Model(
          model.bridge,
          model.health,
          wand,
          cast_index,
          model.active_wand_index,
          model.total_wands,
          model.edit_mode,
          model.all_wands,
          model.hovered_wand,
          model.hovered_spell,
        ),
        $effect.none(),
      ];
    } else if ($ instanceof ActiveWandChanged) {
      let index = $.index;
      let total = $.total_wands;
      return [
        new Model(
          model.bridge,
          model.health,
          model.active_wand,
          model.cast_index,
          index,
          total,
          model.edit_mode,
          model.all_wands,
          model.hovered_wand,
          model.hovered_spell,
        ),
        $effect.none(),
      ];
    } else {
      let is_open = $.is_open;
      let wands = $.wands;
      return [
        new Model(
          model.bridge,
          model.health,
          model.active_wand,
          model.cast_index,
          model.active_wand_index,
          model.total_wands,
          is_open,
          wands,
          new $option.None(),
          new $option.None(),
        ),
        $effect.none(),
      ];
    }
  } else if (msg instanceof HoverWand) {
    let wand_index = msg[0];
    let _block;
    if (wand_index instanceof $option.Some) {
      _block = model.hovered_spell;
    } else {
      _block = wand_index;
    }
    let new_hovered_spell = _block;
    return [
      new Model(
        model.bridge,
        model.health,
        model.active_wand,
        model.cast_index,
        model.active_wand_index,
        model.total_wands,
        model.edit_mode,
        model.all_wands,
        wand_index,
        new_hovered_spell,
      ),
      $effect.none(),
    ];
  } else {
    let spell_opt = msg[0];
    return [
      new Model(
        model.bridge,
        model.health,
        model.active_wand,
        model.cast_index,
        model.active_wand_index,
        model.total_wands,
        model.edit_mode,
        model.all_wands,
        model.hovered_wand,
        spell_opt,
      ),
      $effect.none(),
    ];
  }
}

function view_tooltip_stat(label, value, color) {
  return $html.div(
    toList([class$("flex justify-between")]),
    toList([
      $html.span(toList([class$("text-gray-400")]), toList([$html.text(label)])),
      $html.span(
        toList([class$(color + " font-mono")]),
        toList([$html.text(value)]),
      ),
    ]),
  );
}

function view_wand_tooltip_content(wand_info) {
  let $ = wand_info.wand;
  if ($ instanceof $option.Some) {
    let w = $[0];
    let cast_delay_ms = $float.round(
      $duration.to_seconds(w.cast_delay) * 1000.0,
    );
    let recharge_ms = $float.round(
      $duration.to_seconds(w.recharge_time) * 1000.0,
    );
    return $html.div(
      toList([class$("flex flex-col gap-3")]),
      toList([
        $html.div(
          toList([
            class$("text-white font-bold text-lg border-b border-gray-700 pb-2"),
          ]),
          toList([$html.text(w.name)]),
        ),
        $html.div(
          toList([class$("flex flex-col gap-2 text-sm")]),
          toList([
            view_tooltip_stat(
              "Mana",
              $int.to_string($float.round(w.max_mana)),
              "text-blue-400",
            ),
            view_tooltip_stat(
              "Mana Recharge",
              $float.to_string(w.mana_recharge_rate) + "/s",
              "text-blue-300",
            ),
            view_tooltip_stat(
              "Cast Delay",
              $int.to_string(cast_delay_ms) + "ms",
              "text-yellow-400",
            ),
            view_tooltip_stat(
              "Recharge Time",
              $int.to_string(recharge_ms) + "ms",
              "text-orange-400",
            ),
            view_tooltip_stat(
              "Spells/Cast",
              $int.to_string(w.spells_per_cast),
              "text-purple-400",
            ),
            view_tooltip_stat(
              "Spread",
              $float.to_string(w.spread) + "°",
              "text-gray-400",
            ),
          ]),
        ),
        $html.div(
          toList([
            class$("text-gray-500 text-xs mt-2 pt-2 border-t border-gray-700"),
          ]),
          toList([
            $html.text($int.to_string($iv.size(w.slots)) + " spell slots"),
          ]),
        ),
      ]),
    );
  } else {
    return $html.div(
      toList([class$("text-gray-500 text-sm italic text-center")]),
      toList([$html.text("Empty wand slot")]),
    );
  }
}

function view_inventory_spell_slot(slot, slot_index, is_active, wand_index) {
  let _block;
  if (is_active) {
    _block = "border-yellow-400 border-2 shadow-lg shadow-yellow-400/50";
  } else {
    _block = "border-gray-600 border";
  }
  let border_class = _block;
  let _block$1;
  if (slot instanceof $option.Some) {
    _block$1 = "bg-gray-800/90";
  } else {
    _block$1 = "bg-gray-900/60";
  }
  let bg_class = _block$1;
  let _block$2;
  if (slot instanceof $option.Some) {
    _block$2 = new HoverSpell(new $option.Some([wand_index, slot_index]));
  } else {
    _block$2 = new HoverSpell(new $option.None());
  }
  let hover_msg = _block$2;
  return $html.div(
    toList([
      class$(
        ((("w-10 h-10 " + border_class) + " ") + bg_class) + " rounded flex items-center justify-center relative cursor-pointer hover:bg-gray-700/90 transition-colors",
      ),
      $event.on_mouse_enter(hover_msg),
    ]),
    toList([
      (() => {
        if (slot instanceof $option.Some) {
          let s = slot[0];
          let ui_sprite = s.ui_sprite;
          return $html.img(
            toList([
              $attribute.src(ui_sprite),
              $attribute.alt($spell.name(s)),
              class$("w-8 h-8 object-contain"),
            ]),
          );
        } else {
          return $html.span(
            toList([class$("text-gray-600 text-xs")]),
            toList([$html.text($int.to_string(slot_index + 1))]),
          );
        }
      })(),
    ]),
  );
}

function view_inventory_spell_slots(slots, cast_index, wand_index) {
  return $html.div(
    toList([class$("flex gap-1 mt-1")]),
    (() => {
      let _pipe = slots;
      let _pipe$1 = $iv.index_map(
        _pipe,
        (slot, i) => {
          return view_inventory_spell_slot(
            slot,
            i,
            i === cast_index,
            wand_index,
          );
        },
      );
      return $iv.to_list(_pipe$1);
    })(),
  );
}

function view_inventory_wand(wand_info, index, is_active) {
  let _block;
  if (is_active) {
    _block = "border-yellow-400 border-2";
  } else {
    _block = "border-gray-700 border";
  }
  let border_class = _block;
  let _block$1;
  if (is_active) {
    _block$1 = "text-yellow-400";
  } else {
    _block$1 = "text-gray-400";
  }
  let label_class = _block$1;
  return $html.div(
    toList([
      class$(
        ("flex items-start gap-4 " + border_class) + " rounded-lg p-3 bg-gray-800/50 cursor-pointer hover:bg-gray-700/50 transition-colors",
      ),
      $event.on_mouse_enter(new HoverWand(new $option.Some(index))),
      $event.on_mouse_leave(new HoverWand(new $option.None())),
    ]),
    toList([
      $html.div(
        toList([class$(("text-2xl font-bold " + label_class) + " w-8")]),
        toList([$html.text($int.to_string(index + 1))]),
      ),
      (() => {
        let $ = wand_info.wand;
        if ($ instanceof $option.Some) {
          let w = $[0];
          let mana_pct = (divideFloat(w.current_mana, w.max_mana)) * 100.0;
          let current_mana = $float.round(w.current_mana);
          let max_mana = $float.round(w.max_mana);
          return $html.div(
            toList([class$("flex flex-col gap-2 flex-1")]),
            toList([
              $html.div(
                toList([class$("text-white font-semibold")]),
                toList([$html.text(w.name)]),
              ),
              $html.div(
                toList([class$("flex items-center gap-2")]),
                toList([
                  $html.div(
                    toList([class$("text-blue-300 text-xs font-mono w-20")]),
                    toList([
                      $html.text(
                        ($int.to_string(current_mana) + "/") + $int.to_string(
                          max_mana,
                        ),
                      ),
                    ]),
                  ),
                  $html.div(
                    toList([
                      class$("flex-1 h-2 bg-gray-700 rounded overflow-hidden"),
                    ]),
                    toList([
                      $html.div(
                        toList([
                          class$("h-full bg-blue-500"),
                          style("width", $float.to_string(mana_pct) + "%"),
                        ]),
                        toList([]),
                      ),
                    ]),
                  ),
                ]),
              ),
              view_inventory_spell_slots(w.slots, wand_info.cast_index, index),
            ]),
          );
        } else {
          return $html.div(
            toList([class$("text-gray-500 italic")]),
            toList([$html.text("Empty slot")]),
          );
        }
      })(),
    ]),
  );
}

function view_damage_spell_tooltip(s) {
  let cast_delay_ms = $float.round(
    $duration.to_seconds(s.cast_delay_addition) * 1000.0,
  );
  let lifetime_ms = $float.round(
    $duration.to_seconds(s.projectile_lifetime) * 1000.0,
  );
  return $html.div(
    toList([class$("flex flex-col gap-3")]),
    toList([
      $html.div(
        toList([
          class$(
            "text-yellow-300 font-bold text-lg border-b border-gray-700 pb-2",
          ),
        ]),
        toList([$html.text(s.name)]),
      ),
      $html.div(
        toList([class$("text-gray-500 text-xs -mt-2 mb-1")]),
        toList([$html.text("Projectile Spell")]),
      ),
      $html.div(
        toList([class$("flex flex-col gap-2 text-sm")]),
        toList([
          view_tooltip_stat(
            "Mana Cost",
            $int.to_string($float.round(s.mana_cost)),
            "text-blue-400",
          ),
          view_tooltip_stat(
            "Damage",
            $int.to_string($float.round(s.damage)),
            "text-red-400",
          ),
          view_tooltip_stat(
            "Speed",
            $int.to_string($float.round(s.projectile_speed)),
            "text-cyan-400",
          ),
          view_tooltip_stat(
            "Lifetime",
            $int.to_string(lifetime_ms) + "ms",
            "text-gray-400",
          ),
          view_tooltip_stat(
            "Cast Delay",
            $int.to_string(cast_delay_ms) + "ms",
            "text-yellow-400",
          ),
          view_tooltip_stat(
            "Crit Chance",
            $float.to_string(s.critical_chance * 100.0) + "%",
            "text-orange-400",
          ),
          view_tooltip_stat(
            "Spread",
            $float.to_string(s.spread) + "°",
            "text-gray-400",
          ),
        ]),
      ),
      (() => {
        let $ = s.has_trigger;
        if ($) {
          return $html.div(
            toList([
              class$(
                "text-purple-400 text-xs mt-2 pt-2 border-t border-gray-700",
              ),
            ]),
            toList([$html.text("Has Trigger")]),
          );
        } else {
          return $html.text("");
        }
      })(),
    ]),
  );
}

function view_multicast_spell_tooltip(s) {
  let _block;
  let $ = s.spell_count;
  if ($ instanceof $spell.Fixed) {
    let n = $[0];
    _block = $int.to_string(n) + " spells";
  } else {
    _block = "All remaining";
  }
  let spell_count_text = _block;
  return $html.div(
    toList([class$("flex flex-col gap-3")]),
    toList([
      $html.div(
        toList([
          class$(
            "text-blue-400 font-bold text-lg border-b border-gray-700 pb-2",
          ),
        ]),
        toList([$html.text(s.name)]),
      ),
      $html.div(
        toList([class$("text-gray-500 text-xs -mt-2 mb-1")]),
        toList([$html.text("Multicast Spell")]),
      ),
      $html.div(
        toList([class$("flex flex-col gap-2 text-sm")]),
        toList([
          view_tooltip_stat(
            "Mana Cost",
            $int.to_string($float.round(s.mana_cost)),
            "text-blue-400",
          ),
          view_tooltip_stat("Casts", spell_count_text, "text-purple-400"),
          (() => {
            let $1 = s.draw_add > 0;
            if ($1) {
              return view_tooltip_stat(
                "Extra Draw",
                "+" + $int.to_string(s.draw_add),
                "text-green-400",
              );
            } else {
              return $html.text("");
            }
          })(),
        ]),
      ),
    ]),
  );
}

function format_modifier(value) {
  let $ = value >= 0.0;
  if ($) {
    return "+" + $int.to_string($float.round(value));
  } else {
    return $int.to_string($float.round(value));
  }
}

function format_modifier_int(value) {
  let $ = value >= 0;
  if ($) {
    return "+" + $int.to_string(value);
  } else {
    return $int.to_string(value);
  }
}

function view_modifier_spell_tooltip(s) {
  let cast_delay_ms = $float.round(
    $duration.to_seconds(s.cast_delay_addition) * 1000.0,
  );
  let recharge_ms = $float.round(
    $duration.to_seconds(s.recharge_addition) * 1000.0,
  );
  return $html.div(
    toList([class$("flex flex-col gap-3")]),
    toList([
      $html.div(
        toList([
          class$(
            "text-green-400 font-bold text-lg border-b border-gray-700 pb-2",
          ),
        ]),
        toList([$html.text(s.name)]),
      ),
      $html.div(
        toList([class$("text-gray-500 text-xs -mt-2 mb-1")]),
        toList([$html.text("Modifier Spell")]),
      ),
      $html.div(
        toList([class$("flex flex-col gap-2 text-sm")]),
        toList([
          view_tooltip_stat(
            "Mana Cost",
            $int.to_string($float.round(s.mana_cost)),
            "text-blue-400",
          ),
          (() => {
            let $ = s.damage_addition !== 0.0;
            if ($) {
              return view_tooltip_stat(
                "Damage +",
                format_modifier(s.damage_addition),
                "text-red-400",
              );
            } else {
              return $html.text("");
            }
          })(),
          (() => {
            let $ = s.damage_multiplier !== 1.0;
            if ($) {
              return view_tooltip_stat(
                "Damage ×",
                $float.to_string(s.damage_multiplier),
                "text-red-400",
              );
            } else {
              return $html.text("");
            }
          })(),
          (() => {
            let $ = s.projectile_speed_addition !== 0.0;
            if ($) {
              return view_tooltip_stat(
                "Speed +",
                format_modifier(s.projectile_speed_addition),
                "text-cyan-400",
              );
            } else {
              return $html.text("");
            }
          })(),
          (() => {
            let $ = s.projectile_speed_multiplier !== 1.0;
            if ($) {
              return view_tooltip_stat(
                "Speed ×",
                $float.to_string(s.projectile_speed_multiplier),
                "text-cyan-400",
              );
            } else {
              return $html.text("");
            }
          })(),
          (() => {
            let $ = cast_delay_ms !== 0;
            if ($) {
              return view_tooltip_stat(
                "Cast Delay",
                format_modifier_int(cast_delay_ms) + "ms",
                "text-yellow-400",
              );
            } else {
              return $html.text("");
            }
          })(),
          (() => {
            let $ = recharge_ms !== 0;
            if ($) {
              return view_tooltip_stat(
                "Recharge",
                format_modifier_int(recharge_ms) + "ms",
                "text-orange-400",
              );
            } else {
              return $html.text("");
            }
          })(),
        ]),
      ),
      (() => {
        let $ = s.adds_trigger;
        if ($) {
          return $html.div(
            toList([
              class$(
                "text-purple-400 text-xs mt-2 pt-2 border-t border-gray-700",
              ),
            ]),
            toList([$html.text("Adds Trigger to next spell")]),
          );
        } else {
          return $html.text("");
        }
      })(),
    ]),
  );
}

function view_spell_tooltip_content(s) {
  if (s instanceof $spell.DamageSpell) {
    let kind = s.kind;
    return view_damage_spell_tooltip(kind);
  } else if (s instanceof $spell.ModifierSpell) {
    let kind = s.kind;
    return view_modifier_spell_tooltip(kind);
  } else {
    let kind = s.kind;
    return view_multicast_spell_tooltip(kind);
  }
}

function view_inventory(
  wands,
  active_index,
  hovered_wand,
  hovered_spell_indices
) {
  let _block;
  if (hovered_wand instanceof $option.Some) {
    let idx = hovered_wand[0];
    let _pipe = wands;
    let _pipe$1 = $list.drop(_pipe, idx);
    let _pipe$2 = $list.first(_pipe$1);
    _block = $result.unwrap(_pipe$2, new WandInfo(new $option.None(), 0));
  } else {
    _block = new WandInfo(new $option.None(), 0);
  }
  let hovered_wand_info = _block;
  let _block$1;
  if (hovered_spell_indices instanceof $option.Some) {
    let wand_idx = hovered_spell_indices[0][0];
    let slot_idx = hovered_spell_indices[0][1];
    let _pipe = wands;
    let _pipe$1 = $list.drop(_pipe, wand_idx);
    let _pipe$2 = $list.first(_pipe$1);
    let _pipe$3 = $result.map(
      _pipe$2,
      (wand_info) => {
        let $ = wand_info.wand;
        if ($ instanceof $option.Some) {
          let w = $[0];
          let _pipe$3 = $iv.get(w.slots, slot_idx);
          return $result.unwrap(_pipe$3, new $option.None());
        } else {
          return $;
        }
      },
    );
    _block$1 = $result.unwrap(_pipe$3, new $option.None());
  } else {
    _block$1 = hovered_spell_indices;
  }
  let hovered_spell = _block$1;
  return $html.div(
    toList([
      class$(
        "fixed inset-0 z-50 bg-black/70 flex items-center justify-center pointer-events-auto",
      ),
    ]),
    toList([
      $html.div(
        toList([class$("relative")]),
        toList([
          $html.div(
            toList([class$("bg-gray-900/95 rounded-lg p-6 max-w-2xl")]),
            toList([
              $html.div(
                toList([class$("text-white text-xl font-bold mb-4 text-center")]),
                toList([$html.text("Inventory")]),
              ),
              $html.div(
                toList([class$("text-gray-400 text-sm mb-6 text-center")]),
                toList([$html.text("Press I to close")]),
              ),
              $html.div(
                toList([class$("flex flex-col gap-4")]),
                (() => {
                  let _pipe = wands;
                  return $list.index_map(
                    _pipe,
                    (wand_info, idx) => {
                      return view_inventory_wand(
                        wand_info,
                        idx,
                        idx === active_index,
                      );
                    },
                  );
                })(),
              ),
            ]),
          ),
          $html.div(
            toList([
              class$("absolute left-full top-0 ml-4 flex flex-col gap-4 w-64"),
            ]),
            toList([
              $html.div(
                toList([class$("bg-gray-900/95 rounded-lg p-4")]),
                toList([
                  (() => {
                    if (hovered_wand instanceof $option.Some) {
                      return view_wand_tooltip_content(hovered_wand_info);
                    } else {
                      return $html.div(
                        toList([
                          class$("text-gray-500 text-sm italic text-center"),
                        ]),
                        toList([$html.text("Hover over a wand to see details")]),
                      );
                    }
                  })(),
                ]),
              ),
              $html.div(
                toList([class$("bg-gray-900/95 rounded-lg p-4")]),
                toList([
                  (() => {
                    if (hovered_spell instanceof $option.Some) {
                      let s = hovered_spell[0];
                      return view_spell_tooltip_content(s);
                    } else {
                      return $html.div(
                        toList([
                          class$("text-gray-500 text-sm italic text-center"),
                        ]),
                        toList([$html.text("Hover over a spell to see details")]),
                      );
                    }
                  })(),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    ]),
  );
}

function view_health(h) {
  let pct = $health.percentage(h) * 100.0;
  let current = $float.round($health.current(h));
  let max = $float.round($health.max(h));
  return $html.div(
    toList([class$("flex flex-col gap-1")]),
    toList([
      $html.div(
        toList([class$("text-white text-sm font-mono drop-shadow-md")]),
        toList([
          $html.text(
            (("HP: " + $int.to_string(current)) + "/") + $int.to_string(max),
          ),
        ]),
      ),
      $html.div(
        toList([class$("w-40 h-3 bg-gray-800/80 rounded overflow-hidden")]),
        toList([
          $html.div(
            toList([
              class$("h-full bg-red-500 duration-100"),
              style("width", $float.to_string(pct) + "%"),
            ]),
            toList([]),
          ),
        ]),
      ),
    ]),
  );
}

function view_spell_slot(slot, index, is_active) {
  let _block;
  if (is_active) {
    _block = "border-yellow-400 border-2 shadow-lg shadow-yellow-400/50";
  } else {
    _block = "border-gray-600 border";
  }
  let border_class = _block;
  let _block$1;
  if (slot instanceof $option.Some) {
    _block$1 = "bg-gray-800/90";
  } else {
    _block$1 = "bg-gray-900/60";
  }
  let bg_class = _block$1;
  return $html.div(
    toList([
      class$(
        ((("w-10 h-10 " + border_class) + " ") + bg_class) + " rounded flex items-center justify-center relative",
      ),
    ]),
    toList([
      (() => {
        if (slot instanceof $option.Some) {
          let s = slot[0];
          let ui_sprite = s.ui_sprite;
          return $html.img(
            toList([
              $attribute.src(ui_sprite),
              $attribute.alt($spell.name(s)),
              class$("w-8 h-8 object-contain"),
            ]),
          );
        } else {
          return $html.span(
            toList([class$("text-gray-600 text-xs")]),
            toList([$html.text($int.to_string(index + 1))]),
          );
        }
      })(),
    ]),
  );
}

function view_spell_slots(slots, cast_index) {
  return $html.div(
    toList([class$("flex gap-1 mt-1")]),
    (() => {
      let _pipe = slots;
      let _pipe$1 = $iv.index_map(
        _pipe,
        (slot, i) => { return view_spell_slot(slot, i, i === cast_index); },
      );
      return $iv.to_list(_pipe$1);
    })(),
  );
}

function view_wand(wand_opt, cast_index, wand_index) {
  if (wand_opt instanceof $option.Some) {
    let w = wand_opt[0];
    let mana_pct = (divideFloat(w.current_mana, w.max_mana)) * 100.0;
    let current_mana = $float.round(w.current_mana);
    let max_mana = $float.round(w.max_mana);
    return $html.div(
      toList([class$("flex flex-col gap-1")]),
      toList([
        $html.div(
          toList([class$("text-white text-sm drop-shadow-md")]),
          toList([
            $html.text((("[" + $int.to_string(wand_index + 1)) + "] ") + w.name),
          ]),
        ),
        $html.div(
          toList([class$("text-blue-300 text-xs font-mono drop-shadow-md")]),
          toList([
            $html.text(
              (("Mana: " + $int.to_string(current_mana)) + "/") + $int.to_string(
                max_mana,
              ),
            ),
          ]),
        ),
        $html.div(
          toList([class$("w-40 h-3 bg-gray-800/80 rounded overflow-hidden")]),
          toList([
            $html.div(
              toList([
                class$("h-full bg-blue-500 transition-all duration-100"),
                style("width", $float.to_string(mana_pct) + "%"),
              ]),
              toList([]),
            ),
          ]),
        ),
        view_spell_slots(w.slots, cast_index),
      ]),
    );
  } else {
    return $html.div(
      toList([class$("text-gray-400 text-sm")]),
      toList([$html.text("No wand equipped")]),
    );
  }
}

function view(model) {
  return $html.div(
    toList([class$("pointer-events-none")]),
    toList([
      $html.div(
        toList([class$("fixed top-4 left-4 flex flex-col gap-3")]),
        toList([
          view_health(model.health),
          view_wand(
            model.active_wand,
            model.cast_index,
            model.active_wand_index,
          ),
        ]),
      ),
      (() => {
        let $ = model.edit_mode;
        if ($) {
          return view_inventory(
            model.all_wands,
            model.active_wand_index,
            model.hovered_wand,
            model.hovered_spell,
          );
        } else {
          return $html.text("");
        }
      })(),
    ]),
  );
}

export function start(bridge) {
  let _pipe = $lustre.application(init, update, view);
  let _pipe$1 = $lustre.start(_pipe, "#ui", bridge);
  return $result.map(_pipe$1, (_) => { return undefined; });
}
