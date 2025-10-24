pub type Id {
  Camera(layer: Layer)
  Box(layer: Layer)
  Ambient(layer: Layer)
  Directional(layer: Layer)
  Ground(layer: Layer)
  Enemy(layer: Layer, id: Int)
  Player(layer: Layer)
  Projectile(layer: Layer, id: Int)
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

pub fn box() {
  Box(layer: MapLayer)
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

pub fn player() {
  Player(layer: PlayerLayer)
}

pub fn projectile(id: Int) -> Id {
  Projectile(layer: PlayerLayer, id: id)
}
