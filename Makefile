APP_NAME = Claude Toolbar
BUNDLE_ID = com.claude-toolbar
BUILD_DIR = .build/release
APP_DIR = $(APP_NAME).app

.PHONY: build run app clean

build:
	swift build

run:
	swift run

release:
	swift build -c release

app: release
	@echo "Creating $(APP_DIR)..."
	@rm -rf "$(APP_DIR)"
	@mkdir -p "$(APP_DIR)/Contents/MacOS"
	@mkdir -p "$(APP_DIR)/Contents/Resources"
	@cp $(BUILD_DIR)/ClaudeToolbar "$(APP_DIR)/Contents/MacOS/"
	@cp -r $(BUILD_DIR)/ClaudeToolbar_ClaudeToolbar.bundle "$(APP_DIR)/Contents/Resources/" 2>/dev/null || true
	@cp Info.plist "$(APP_DIR)/Contents/"
	@echo "APPL????" > "$(APP_DIR)/Contents/PkgInfo"
	@codesign --force --sign - --identifier $(BUNDLE_ID) "$(APP_DIR)"
	@echo "Built and signed $(APP_DIR)"

install: app
	@cp -r "$(APP_DIR)" /Applications/
	@echo "Installed to /Applications/$(APP_DIR)"

clean:
	swift package clean
	rm -rf "$(APP_DIR)"
