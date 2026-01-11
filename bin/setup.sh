#!/usr/bin/env bash

set -e

echo "🎵 Musical Patterns Setup"
echo "========================="
echo ""

# Check Node version
NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
if [[ -z "$NODE_VERSION" ]]; then
    echo "❌ Node.js is not installed. Please install Node.js 16.x"
    echo "   We recommend using nvm: https://github.com/nvm-sh/nvm"
    echo "   Then run: nvm install 16 && nvm use 16"
    exit 1
elif [[ "$NODE_VERSION" -gt 16 ]]; then
    echo "⚠️  Warning: You're using Node.js v$(node -v | cut -d'v' -f2)"
    echo "   This project requires Node 16 due to native dependencies (node-sass)."
    echo "   Please run: nvm install 16 && nvm use 16"
    echo "   Then re-run: make setup"
    exit 1
fi
echo "✓ Node.js v$(node -v | cut -d'v' -f2) detected"

# Initialize all submodules (services and patterns)
echo ""
echo "📦 Initializing git submodules..."
git submodule update --init --recursive

# Checkout main branch in all submodules
echo "🔄 Checking out main branch in all submodules..."
git submodule foreach --recursive 'git checkout main 2>/dev/null || true'

# Install dependencies in the lab (this pulls all @musical-patterns packages from npm)
echo ""
echo "📥 Installing dependencies in services/lab..."
pushd services/lab > /dev/null
npm install
popd > /dev/null

# Copy shared config files from CLI to lab
# (The CLI's postinstall script uses grep -P which doesn't work on macOS,
# so we do this manually here)
echo ""
echo "📋 Copying shared configuration files..."
CLI_SHARE="services/lab/node_modules/@musical-patterns/cli/share"
LAB="services/lab"

# Create directories
mkdir -p "${LAB}/bin"
mkdir -p "${LAB}/test"

# Copy essential files
cp "${CLI_SHARE}/bin/port.js" "${LAB}/bin/"
cp "${CLI_SHARE}/bin/update.sh" "${LAB}/bin/"

# Copy webpack configs (only if they don't already exist in lab)
for config in webpack.common.js webpack.dev.js webpack.local.js webpack.prod.js webpack.deploy.js webpack.library.js webpack.publish.js webpack.qa.js; do
    if [[ ! -f "${LAB}/${config}" ]]; then
        cp "${CLI_SHARE}/${config}" "${LAB}/" 2>/dev/null || true
    fi
done

# Copy tsconfig files (only if they don't already exist)
for config in tsconfig.common.json tsconfig.node.json; do
    if [[ ! -f "${LAB}/${config}" ]]; then
        cp "${CLI_SHARE}/${config}" "${LAB}/" 2>/dev/null || true
    fi
done

# Copy test support files
for testfile in jasmine.js mockDom.ts noFailureOnNonEmptySuite.ts reporter.ts setup.ts; do
    cp "${CLI_SHARE}/test/${testfile}" "${LAB}/test/" 2>/dev/null || true
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the app locally, run:"
echo "  make start"
echo ""
echo "The app will open at http://localhost:8083"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Optional: For deployment to Google Cloud, you'll need:"
echo "  - Google Cloud SDK (gcloud) installed"
echo "  - Run: gcloud config configurations create musical-patterns"
echo "  - Run: gcloud config set project musical-patterns"
