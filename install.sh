#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "==> Installing Hex and Rebar..."
mix local.hex --force
mix local.rebar --force

echo "==> Installing dependencies..."
mix deps.get

echo "==> Compiling..."
mix compile

echo "==> Setting up database..."
mix ecto.create || true
mix ecto.migrate

echo "==> Seeding demo data..."
mix run priv/repo/seeds.exs

echo ""
echo "✅ Install complete! Start the server with: mix phx.server"
echo "   Then open http://localhost:4000"
echo "   Demo login: cenius@cenius.ai / cenius"
