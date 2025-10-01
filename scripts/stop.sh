#!/usr/bin/env bash
set -e

echo "➜ Stopping FSC Portal services..."

# Kill uvicorn (backend)
pkill -f "uvicorn main:app" || true

# Kill frontend preview/serve
pkill -f "vite preview" || true
pkill -f "serve -s dist" || true

echo "✓ All FSC Portal processes stopped."
