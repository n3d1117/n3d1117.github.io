TARGET := iphone:clang:latest:13.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = RunawayPrefs

RunawayPrefs_FILES = RAPRootListController.m
RunawayPrefs_FRAMEWORKS = UIKit Foundation
RunawayPrefs_PRIVATE_FRAMEWORKS = Preferences
RunawayPrefs_INSTALL_PATH = /Library/PreferenceBundles
RunawayPrefs_CFLAGS = -fobjc-arc
ARCHS = arm64 arm64e

include $(THEOS_MAKE_PATH)/bundle.mk
