INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Runaway
Runaway_FILES = Tweak.xm
Runaway_CFLAGS = -fobjc-arc
ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:12.0

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += runawayprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
