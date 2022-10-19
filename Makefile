all: build package clean

PROJECT = $(shell basename *.xcodeproj)
TARGET = $(shell basename *.xcodeproj .xcodeproj)
CONFIGURATION = Release
SDK = iphoneos

build:
	echo "Building $(TARGET) for $(SDK)..."
	xcodebuild -project $(PROJECT) -target $(TARGET) -configuration $(CONFIGURATION) -sdk $(SDK) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO clean build

package:
	rm -rf Payload
	mkdir Payload
	cp -r build/$(CONFIGURATION)-$(SDK)/$(TARGET).app Payload
	zip -r $(TARGET).ipa Payload

clean:
	rm -rf Payload
	rm -rf build

