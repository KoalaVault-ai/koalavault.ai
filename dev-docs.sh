#!/bin/bash

# Mintlify Local Preview Script

set -e

# Show usage information
show_usage() {
    echo "Usage: $0 [COMMAND|PORT]"
    echo ""
    echo "Commands:"
    echo "  c, check-links    Validate all links in documentation"
    echo "  PORT              Run dev server on custom port (default: 3000)"
    echo "  (no args)         Run dev server on port 3000"
    echo ""
    echo "Examples:"
    echo "  $0                  # Start dev server on port 3000"
    echo "  $0 3333             # Start dev server on port 3333"
    echo "  $0 c                # Check for broken links"
    echo "  $0 check-links      # Check for broken links"
}

echo "🔍 Checking if Mintlify CLI is installed..."

# Check if mint command exists
if ! command -v mint &> /dev/null; then
    echo "📦 Mintlify CLI not found, installing..."
    npm i -g mint
    echo "✅ Mintlify CLI installed successfully"
else
    echo "✅ Mintlify CLI is already installed"
fi

# Navigate to docs directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$SCRIPT_DIR/docs"

if [ ! -d "$DOCS_DIR" ]; then
    echo "❌ Error: docs directory not found"
    exit 1
fi

echo "📂 Navigating to docs directory: $DOCS_DIR"
cd "$DOCS_DIR"

# Check if docs.json exists
if [ ! -f "docs.json" ]; then
    echo "⚠️  Warning: docs.json file not found"
fi

# Handle commands
if [ "$1" = "c" ] || [ "$1" = "check-links" ] || [ "$1" = "--check-links" ]; then
    # Validate links
    echo "🔗 Validating links in documentation..."
    mint broken-links
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
elif [ -n "$1" ]; then
    # Custom port
    echo "🚀 Starting Mintlify local preview..."
    echo "🔌 Using custom port: $1"
    echo "📍 Preview URL: http://localhost:$1"
    echo "💡 Tip: Press Ctrl+C to stop the server"
    echo ""
    mint dev --port "$1"
else
    # Default port 3000
    echo "🚀 Starting Mintlify local preview..."
    echo "📍 Preview URL: http://localhost:3000"
    echo "💡 Tip: Press Ctrl+C to stop the server"
    echo ""
    mint dev
fi

