.PHONY: build publish

build:
	eas build --platform android --profile android-apk --local

publish:
	eas build --platform android --profile production