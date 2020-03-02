include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = runawayprefs

runawayprefs_FILES = RAPRootListController.m
runawayprefs_INSTALL_PATH = /Library/PreferenceBundles
runawayprefs_FRAMEWORKS = UIKit
runawayprefs_PRIVATE_FRAMEWORKS = Preferences
runawayprefs_CFLAGS = -fobjc-arc
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/runawayprefs.plist$(ECHO_END)
