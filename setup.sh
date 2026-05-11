#!/usr/bin/env bash
set -euo pipefail

echo "==> Saffron project setup"

if ! command -v brew &>/dev/null; then
  echo "  ✗ Homebrew not found. Install it from https://brew.sh"
  exit 1
fi

if ! command -v xcodegen &>/dev/null; then
  echo "  → Installing XcodeGen..."
  brew install xcodegen
fi

echo "  → Generating Saffron.xcodeproj..."
xcodegen generate

echo ""
echo "  ✓ Done. Open Saffron.xcodeproj in Xcode 15+."
echo ""
echo "  Next steps:"
echo "  1. Set your Development Team in Xcode → Signing & Capabilities"
echo "  2. Deploy the worker:  cd worker && npm install && wrangler secret put ANTHROPIC_API_KEY && npm run deploy"
echo "  3. Add EXTRACTION_API_URL to your scheme's environment variables (or update Config.swift)"
echo "  4. Build and run on a device (CloudKit requires real device or signed simulator)"
