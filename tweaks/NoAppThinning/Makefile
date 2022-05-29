include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoAppThinning

NoAppThinning_LDFLAGS = -Wl,-segalign,4000
NoAppThinning_FILES = Tweak.xm
NoAppThinning_ARCHS = armv7 arm64
NoAppThinning_LIBRARIES = MobileGestalt

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 AppStore"