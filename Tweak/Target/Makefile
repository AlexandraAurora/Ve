TWEAK_NAME = VeTarget
VeTarget_FILES = VeTarget.m $(wildcard Controllers/*.m Controllers/Sorter/*.m Cells/*.m ../../Manager/*.m ../../Utils/*.m)
VeTarget_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
VeTarget_FRAMEWORKS = UIKit
VeTarget_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
