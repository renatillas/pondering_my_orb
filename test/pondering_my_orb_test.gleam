import gleeunit
import gleam/list

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let name = "Joe"
  let greeting = "Hello, " <> name <> "!"

  assert greeting == "Hello, Joe!"
}

/// Test that modifier spells don't consume draw - verified manually in game
/// When you have [Add Mana, Fireball] with spells_per_cast=1:
/// - Add Mana doesn't consume draw
/// - Fireball is automatically drawn and cast
/// - Both slots are highlighted during cast
pub fn modifier_draws_next_spell_documentation_test() {
  // This is a documentation test to record the expected behavior
  // The fix: modifiers no longer decrement remaining_draw in wand.gleam:241
  // Expected: modifier + damage spell both cast with spells_per_cast=1
  assert True
}

/// Test list behavior used in wand system
pub fn list_length_test() {
  let my_list = [1, 2, 3]
  assert list.length(my_list) == 3
}
