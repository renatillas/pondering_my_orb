ARG GLEAM_VERSION=v1.14.0

# =============================================================================
# Build stage - compile the application
# =============================================================================
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-elixir AS builder

# ============================================
# SHARED PACKAGE - Base dependency
# ============================================
COPY ./shared/gleam.toml ./shared/manifest.toml /build/shared/

WORKDIR /build/shared
RUN gleam deps download

COPY ./shared/src /build/shared/src

# ============================================
# SERVER - Backend build
# ============================================
COPY ./server/gleam.toml ./server/manifest.toml /build/server/

WORKDIR /build/server
RUN gleam deps download

COPY ./server/src /build/server/src

# Export as Erlang shipment (standalone release)
RUN gleam export erlang-shipment

# =============================================================================
# Runtime stage - slim image with only what's needed to run
# =============================================================================
FROM ghcr.io/gleam-lang/gleam:${GLEAM_VERSION}-erlang-alpine

# Copy the compiled server code from the builder stage
COPY --from=builder /build/server/build/erlang-shipment /app

# Set up the entrypoint
WORKDIR /app
RUN echo -e '#!/bin/sh\nexec ./entrypoint.sh "$@"' > ./start.sh \
  && chmod +x ./start.sh

# Set environment variables
ENV HOST=0.0.0.0
ENV PORT=8080

# Expose the port
EXPOSE $PORT

# Run the server
CMD ["./start.sh", "run"]
