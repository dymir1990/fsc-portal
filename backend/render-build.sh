#!/usr/bin/env bash
set -euo pipefail

echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Build complete!"
