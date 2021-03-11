TARGET := iphone:clang:latest:13.0
INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Runaway
Runaway_FILES = Tweak.xm
Runaway_CFLAGS = -fobjc-arc -Wno-nullability-completeness
Runaway_FRAMEWORKS = UIKit Foundation
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += runawayprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
