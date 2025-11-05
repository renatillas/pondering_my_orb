pub type Id {
  Scene(layer: Layer)
  Camera(layer: Layer)
  Map(layer: Layer)
  Tower(layer: Layer, id: Int)
  Foliage(layer: Layer, id: Int)
  Ambient(layer: Layer)
  Directional(layer: Layer)
  Ground(layer: Layer)
  Enemy(layer: Layer, id: Int)
  EnemySprite(layer: Layer, id: Int)
  EnemyGroup(layer: Layer, id: Int)
  EnemyHealthBar(layer: Layer, id: Int)
  Player(layer: Layer)
  PlayerSprite(layer: Layer)
  Projectile(layer: Layer, id: Int)
  Explosion(layer: Layer, id: Int)
  XPShard(layer: Layer, id: Int)
  LootDrop(layer: Layer, id: Int)
  DamageNumber(layer: Layer, id: Int)
  Chest(layer: Layer, id: Int)
  Crate(layer: Layer, id: Int)
  Elevation(layer: Layer, id: Int)
}

pub type Layer {
  MiscelaniaLayer
  MapLayer
  EnemyLayer
  PlayerLayer
}

pub fn camera() {
  Camera(layer: MiscelaniaLayer)
}

pub fn map() {
  Map(layer: MapLayer)
}

pub fn tower(id: Int) -> Id {
  Tower(layer: MapLayer, id: id)
}

pub fn foliage(id: Int) -> Id {
  Foliage(layer: MapLayer, id: id)
}

pub fn ambient() {
  Ambient(layer: MapLayer)
}

pub fn directional() {
  Directional(layer: MapLayer)
}

pub fn ground() {
  Ground(layer: MapLayer)
}

pub fn enemy(id: Int) -> Id {
  Enemy(layer: EnemyLayer, id: id)
}

pub fn enemy_sprite(id: Int) -> Id {
  EnemySprite(layer: EnemyLayer, id: id)
}

pub fn enemy_group(id: Int) -> Id {
  EnemyGroup(layer: EnemyLayer, id: id)
}

pub fn enemy_health_bar(id: Int) -> Id {
  EnemyHealthBar(layer: EnemyLayer, id: id)
}

pub fn player() {
  Player(layer: PlayerLayer)
}

pub fn player_sprite() {
  PlayerSprite(layer: PlayerLayer)
}

pub fn projectile(id: Int) -> Id {
  Projectile(layer: PlayerLayer, id: id)
}

pub fn explosion(id: Int) -> Id {
  Explosion(layer: PlayerLayer, id: id)
}

pub fn xp_shard(id: Int) -> Id {
  XPShard(layer: MiscelaniaLayer, id: id)
}

pub fn loot_drop(id: Int) -> Id {
  LootDrop(layer: MiscelaniaLayer, id: id)
}

pub fn damage_number(id: Int) -> Id {
  DamageNumber(layer: MiscelaniaLayer, id: id)
}

pub fn chest(id: Int) -> Id {
  Chest(layer: MapLayer, id: id)
}

pub fn crate(id: Int) -> Id {
  Crate(layer: MapLayer, id: id)
}

pub fn elevation(id: Int) -> Id {
  Elevation(layer: MapLayer, id: id)
}

pub fn scene() -> Id {
  Scene(layer: MiscelaniaLayer)
}
