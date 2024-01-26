export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.4:14.0

INSTALL_TARGET_PROCESSES = SpringBoard Preferences
SUBPROJECTS = Tweak/Core Tweak/Target Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
