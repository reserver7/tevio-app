SHELL := /bin/zsh

ENV ?= development
IOS_SIMULATOR ?= iPhone 17
ANDROID_DEVICE ?= $(shell adb devices 2>/dev/null | awk 'NR > 1 && $$2 == "device" { print $$1; exit }')

JAVA_HOME ?= /opt/homebrew/opt/openjdk@17
ANDROID_SDK_ROOT ?= /opt/homebrew/share/android-commandlinetools
ANDROID_HOME ?= $(ANDROID_SDK_ROOT)
PATH := $(JAVA_HOME)/bin:$(ANDROID_SDK_ROOT)/platform-tools:$(ANDROID_SDK_ROOT)/emulator:$(ANDROID_SDK_ROOT)/cmdline-tools/latest/bin:$(PATH)

export JAVA_HOME ANDROID_HOME ANDROID_SDK_ROOT PATH

API_BASE_URL = https://api.dev.tevio.app
ifeq ($(ENV),staging)
API_BASE_URL = https://api.stg.tevio.app
endif
ifeq ($(ENV),production)
API_BASE_URL = https://api.tevio.app
endif

DART_DEFINES = --dart-define=APP_ENV=$(ENV) --dart-define=API_BASE_URL=$(API_BASE_URL)

.PHONY: setup android ios lint test check clean

setup:
	flutter pub get

android:
	@if [ -z "$(ANDROID_DEVICE)" ]; then \
		echo "No Android device or emulator is running. Start an Android emulator or connect a device, then run make android again."; \
		exit 1; \
	fi
	flutter run -d "$(ANDROID_DEVICE)" --flavor $(ENV) $(DART_DEFINES)

ios:
	xcrun simctl boot "$(IOS_SIMULATOR)" || true
	open -a Simulator
	flutter run -d "$(IOS_SIMULATOR)" $(DART_DEFINES)

lint:
	flutter analyze

test:
	flutter test

check: lint test

clean:
	flutter clean
