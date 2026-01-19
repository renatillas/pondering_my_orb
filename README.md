# 🔮 Pondering My Orb

A multiplayer 3D arena shooter built with Gleam, featuring real-time physics, spell casting, and wave-based enemy combat.

[![CI/CD](https://github.com/renatillas/pondering_my_orb/actions/workflows/deploy.yml/badge.svg)](https://github.com/renatillas/pondering_my_orb/actions)

## ✨ Features

- 🎮 **Real-time multiplayer** with WebSocket connections
- 🌐 **Multi-room system** - create and join game rooms
- ⚔️ **Spell-based combat** with multiple wand types
- 👾 **Wave-based enemy spawning** with AI pathfinding
- 🎯 **Server-authoritative physics** using Expresso
- 🎨 **Beautiful 3D graphics** powered by Tiramisu (Three.js)
- 🖼️ **Responsive UI** built with Lustre

## 🏗️ Architecture

This is a monorepo with three packages:

- **`shared/`** - Shared types and game logic (player, enemy, projectile, etc.)
- **`server/`** - Erlang/OTP multiplayer backend with ewe WebSockets
- **`client/`** - Browser-based 3D client using Tiramisu + Lustre

### Tech Stack

- **Language**: Gleam
- **Server**: Erlang/OTP, ewe (WebSockets), Expresso (physics)
- **Client**: Tiramisu (3D), Lustre (UI), Three.js
- **Deployment**: Fly.io (server), Cloudflare Pages (client)

## 🚀 Quick Start

### Prerequisites

- [Gleam](https://gleam.run/) v1.6.4+
- [Erlang/OTP](https://www.erlang.org/) v27+
- [Bun](https://bun.sh/) (for client dependencies)
- [Just](https://github.com/casey/just) (task runner)

### Development

```bash
# Install dependencies
just deps-download

# Build all packages
just build

# Run tests
just test

# Start server (localhost:8080)
just server-dev

# Start client dev server (localhost:5173)
cd client/dist && python3 -m http.server 5173

# Run both in parallel
just dev-all
```

### Playing the Game

1. Open browser to `http://localhost:5173`
2. Enter your player name
3. Create a room or join an existing one
4. Use **WASD** to move, **mouse** to aim, **right-click** to cast spells
5. Switch wands with **1-4** keys

## 📦 Deployment

### Server (Fly.io)

```bash
# First-time setup
just fly-init

# Deploy
just deploy-server-remote

# View logs
just fly-logs

# Check status
just fly-status
```

### Client (Cloudflare Pages)

```bash
# Build and deploy
just deploy-client
```

### CI/CD

Automatic deployment on push to `main`:
- ✅ Server → Fly.io
- ✅ Client → Cloudflare Pages

#### Required Secrets

Add these to your GitHub repository settings:

- `FLY_API_TOKEN` - Fly.io API token ([get one here](https://fly.io/user/personal_access_tokens))
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `CLOUDFLARE_ACCOUNT_ID` - Cloudflare account ID

## 🛠️ Common Commands

```bash
just build              # Build all packages
just test               # Run tests
just format             # Format code
just server-dev         # Run server locally
just deploy-all         # Deploy server + client
just fly-logs           # View production logs
just health             # Run full health check
```

Run `just` to see all available commands.

## 📖 Project Structure

```
pondering_my_orb/
├── shared/             # Shared game logic
│   └── src/shared/
│       ├── game_message.gleam  # Client-server messages
│       ├── player.gleam        # Player type & logic
│       ├── enemy.gleam         # Enemy type & logic
│       ├── projectile.gleam    # Projectile type
│       └── spell.gleam         # Spell system
├── server/             # Multiplayer backend
│   ├── src/server/
│   │   ├── server.gleam        # Main entry point
│   │   ├── room_registry.gleam # Room management
│   │   ├── room.gleam          # Game room actor
│   │   ├── player.gleam        # Player actor
│   │   ├── enemy.gleam         # Enemy actor
│   │   └── projectile.gleam    # Projectile actor
│   ├── Dockerfile      # Production Docker image
│   └── fly.toml        # Fly.io configuration
└── client/             # 3D game client
    ├── src/client/
    │   ├── client.gleam        # Main game loop
    │   ├── ui.gleam            # Lustre UI
    │   ├── player.gleam        # Player rendering
    │   ├── enemy.gleam         # Enemy rendering
    │   ├── map.gleam           # World/arena rendering
    │   └── network.gleam       # WebSocket client
    └── dist/           # Static assets
```

## 🎯 Game Design

### Combat System
- **4 wand types**: Fire, Ice, Lightning, Arcane
- **Spell casting**: Right-click to shoot projectiles
- **Server-authoritative**: Physics runs on server, client predicts

### Enemy AI
- **Pathfinding**: Enemies chase nearest player
- **Collision avoidance**: Physics-based separation
- **Wave spawning**: Difficulty scales with time

### Networking
- **60Hz tick rate** on server
- **Client-side prediction** for smooth movement
- **Server reconciliation** for accurate positions

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Run `just format` and `just test`
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- [Gleam](https://gleam.run/) - Amazing language
- [Tiramisu](https://hexdocs.pm/tiramisu/) - 3D game engine
- [Lustre](https://hexdocs.pm/lustre/) - Elm-like UI framework
- [ewe](https://hexdocs.pm/ewe/) - WebSocket library
