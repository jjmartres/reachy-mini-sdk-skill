.PHONY: help install install-dev sync upgrade clean package test lint format typecheck validate all

# Default target
help:
	@echo "🤖 Reachy Mini Skill - Available Commands"
	@echo ""
	@echo "📦 Setup:"
	@echo "  make install        Install production dependencies"
	@echo "  make install-dev    Install with dev dependencies"
	@echo "  make sync          Sync dependencies from pyproject.toml"
	@echo "  make upgrade       Upgrade all dependencies"
	@echo ""
	@echo "🔨 Build:"
	@echo "  make package       Package skill to dist/"
	@echo "  make validate      Validate skill structure"
	@echo ""
	@echo "🧪 Development:"
	@echo "  make format        Format code with black"
	@echo "  make lint          Lint code with ruff"
	@echo "  make typecheck     Type check with mypy"
	@echo "  make test          Run tests"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  make clean         Remove build artifacts"
	@echo "  make clean-all     Remove build artifacts and venv"
	@echo ""
	@echo "🚀 Shortcuts:"
	@echo "  make all           Format, lint, typecheck, and package"

# Installation
install:
	@echo "📦 Installing production dependencies..."
	@uv venv -p $$(asdf which python) --clear
	uv sync --no-dev

install-dev:
	@echo "📦 Installing with dev dependencies..."
	uv sync --all-extras

sync:
	@echo "🔄 Syncing dependencies..."
	uv sync

upgrade:
	@echo "⬆️  Upgrading dependencies..."
	uv sync --upgrade

# Build
package:
	@echo "📦 Packaging skill..."
	@mkdir -p dist
	uv run python scripts/package_skill.py skill/ dist/
	@echo "✅ Package created: dist/reachy-mini-sdk.skill"
	@ls -lh dist/reachy-mini-sdk.skill

validate:
	@echo "🔍 Validating skill structure..."
	uv run python scripts/quick_validate.py skill/ || true

# Development
format:
	@echo "🎨 Formatting code..."
	uv run black scripts/

lint:
	@echo "🔍 Linting code..."
	uv run ruff check scripts/

lint-fix:
	@echo "🔧 Linting and fixing code..."
	uv run ruff check scripts/ --fix

typecheck:
	@echo "📝 Type checking..."
	uv run mypy scripts/

test:
	@echo "🧪 Running tests..."
	uv run pytest

# Cleanup
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf dist/
	rm -rf build/
	rm -rf .venv
	rm -rf *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "✅ Clean complete"

clean-all: clean
	@echo "🧹 Removing virtual environment..."
	rm -rf .venv
	@echo "✅ Deep clean complete"

# Combined workflows
all: format lint typecheck package
	@echo "✅ All checks passed and skill packaged!"

# Development workflow
dev: install-dev
	@echo "✅ Development environment ready!"
	@echo ""
	@echo "Quick commands:"
	@echo "  make format      - Format code"
	@echo "  make lint        - Check code quality"
	@echo "  make package     - Build skill package"

# CI workflow
ci: format lint typecheck package
	@echo "✅ CI checks passed!"

# Info
info:
	@echo "📊 Project Information"
	@echo ""
	@echo "Python version:"
	@uv run python --version
	@echo ""
	@echo "Installed packages:"
	@uv pip list
	@echo ""
	@echo "UV version:"
	@uv --version

# Check if skill exists
check:
	@echo "🔍 Checking skill files..."
	@test -f skill/SKILL.md && echo "✅ SKILL.md found" || echo "❌ SKILL.md not found"
	@test -f skill/LICENSE.txt && echo "✅ LICENSE.txt found" || echo "❌ LICENSE.txt not found"
	@test -f skill/METADATA.yaml && echo "✅ METADATA.yaml found" || echo "❌ METADATA.yaml not found"
	@test -d skill/references && echo "✅ references/ found" || echo "❌ references/ not found"
	@test -f dist/reachy-mini-sdk.skill && echo "✅ Package exists" || echo "ℹ️  Package not built yet (run 'make package')"
