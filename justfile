# Pondering My Orb - Monorepo Task Runner
# Usage: just <command>

# Default recipe - show available commands
default:
    @just --list

# =============================================================================
# BUILD COMMANDS
# =============================================================================

# Build all packages (shared, client, server)
build:
    @echo "📦 Building shared package..."
    cd shared && gleam build
    @echo "📦 Building server package..."
    cd server && gleam build
    @echo "📦 Building client package..."
    cd client && gleam build
    @echo "✅ All packages built successfully!"

# Build only shared package
build-shared:
    @echo "📦 Building shared package..."
    cd shared && gleam build

# Build only server package
build-server:
    @echo "📦 Building server package..."
    cd server && gleam build

# Build only client package
build-client:
    @echo "📦 Building client package..."
    cd client && gleam build

# Clean build artifacts from all packages
clean:
    @echo "🧹 Cleaning shared..."
    cd shared && rm -rf build
    @echo "🧹 Cleaning server..."
    cd server && rm -rf build
    @echo "🧹 Cleaning client..."
    cd client && rm -rf build
    @echo "✅ All build artifacts cleaned!"

# Clean and rebuild everything
rebuild: clean build

# =============================================================================
# TEST COMMANDS
# =============================================================================

# Run tests for all packages
test:
    @echo "🧪 Testing shared package..."
    cd shared && gleam test
    @echo "🧪 Testing server package..."
    cd server && gleam test
    @echo "✅ All tests passed!"

# Run tests for shared package only
test-shared:
    @echo "🧪 Testing shared package..."
    cd shared && gleam test

# Run tests for client package only
test-client:
    @echo "🧪 Testing client package..."
    cd client && gleam test

# Run tests with coverage and watch mode
test-watch:
    @echo "👀 Watching tests..."
    watchexec -w shared/src -w shared/test -w client/src -w client/test "just test"

# =============================================================================
# RUN COMMANDS
# =============================================================================

# Run the client in development mode
dev:
    @echo "🎮 Starting client in development mode..."
    cd client && gleam run -m lustre/dev start

# Run the server locally
server-dev:
    @echo "🖥️  Starting server in development mode..."
    cd server && npx wrangler dev

# Deploy server to Cloudflare Workers
server-deploy:
    @echo "🚀 Deploying server to Cloudflare Workers..."
    cd server && wrangler deploy

# Run both client and server in development mode (parallel)
dev-all:
    @echo "🎮 Starting client and server..."
    just dev & just server-dev

# =============================================================================
# FORMAT COMMANDS
# =============================================================================

# Format all Gleam code
format:
    @echo "✨ Formatting shared..."
    cd shared && gleam format
    @echo "✨ Formatting server..."
    cd server && gleam format
    @echo "✨ Formatting client..."
    cd client && gleam format
    @echo "✅ All code formatted!"

# Check formatting without making changes
format-check:
    @echo "🔍 Checking shared formatting..."
    cd shared && gleam format --check
    @echo "🔍 Checking server formatting..."
    cd server && gleam format --check
    @echo "🔍 Checking client formatting..."
    cd client && gleam format --check

# =============================================================================
# DEPENDENCY COMMANDS
# =============================================================================

# Update dependencies for all packages
deps-update:
    @echo "📥 Updating shared dependencies..."
    cd shared && gleam update
    @echo "📥 Updating server dependencies..."
    cd server && gleam update
    @echo "📥 Updating client dependencies..."
    cd client && gleam update
    @echo "✅ All dependencies updated!"

# Download dependencies for all packages
deps-download:
    @echo "📥 Downloading shared dependencies..."
    cd shared && gleam deps download
    @echo "📥 Downloading server dependencies..."
    cd server && gleam deps download
    @echo "📥 Downloading client dependencies..."
    cd client && gleam deps download
    @echo "✅ All dependencies downloaded!"

# =============================================================================
# CI/CD COMMANDS
# =============================================================================

# Run full CI pipeline (format check, build, test)
ci: format-check build test
    @echo "✅ CI pipeline completed successfully!"

# Pre-commit hook - format, build, test
pre-commit: format build test
    @echo "✅ Pre-commit checks passed!"

# =============================================================================
# UTILITY COMMANDS
# =============================================================================

# Show project information
info:
    @echo "📊 Pondering My Orb - Project Info"
    @echo "=================================="
    @echo ""
    @echo "📦 Packages:"
    @echo "  - shared:  Shared types and game logic"
    @echo "  - client:  Browser game client (Tiramisu + Lustre)"
    @echo "  - server:  Cloudflare Workers multiplayer backend"
    @echo ""
    @echo "🔧 Tech Stack:"
    @echo "  - Language: Gleam"
    @echo "  - Client:   Tiramisu (3D), Lustre (UI)"
    @echo "  - Server:   Cloudflare Workers + Durable Objects"
    @echo ""
    @echo "📝 Common Commands:"
    @echo "  just build     - Build all packages"
    @echo "  just test      - Run all tests"
    @echo "  just dev       - Start client dev server"
    @echo "  just dev-all   - Start client + server"
    @echo "  just format    - Format all code"

# Check project health (dependencies, formatting, tests)
health: deps-download format-check build test
    @echo "💚 Project health check passed!"
