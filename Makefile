.PHONY: build run clean install test help

# Default target
help:
	@echo "Bulk File Renaming Utility - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make build      - Build the release version"
	@echo "  make run        - Run the application"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make install    - Install to /usr/local/bin"
	@echo "  make test       - Run tests (if available)"
	@echo "  make help       - Show this help message"

# Build release version
build:
	@echo "Building release version..."
	swift build -c release
	@echo "✅ Build complete: .build/release/bulk-renamer"

# Run the application
run:
	@echo "Starting Bulk File Renaming Utility..."
	swift run

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf .build
	@echo "✅ Clean complete"

# Install to system
install: build
	@echo "Installing to /usr/local/bin..."
	sudo cp .build/release/bulk-renamer /usr/local/bin/
	sudo chmod +x /usr/local/bin/bulk-renamer
	@echo "✅ Installation complete"
	@echo "You can now run 'bulk-renamer' from anywhere"

# Uninstall from system
uninstall:
	@echo "Uninstalling from /usr/local/bin..."
	sudo rm -f /usr/local/bin/bulk-renamer
	@echo "✅ Uninstallation complete"

# Run tests
test:
	@echo "Running tests..."
	swift test

# Quick test build
test-build:
	@echo "Testing debug build..."
	swift build
	@echo "✅ Debug build successful"
