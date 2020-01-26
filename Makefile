INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang::8.0
THEOS_DEVICE_IP = 192.168.0.176

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BuzzTime

BuzzTime_FILES = BuzzTime.x
BuzzTime_CFLAGS = -fobjc-arc
BuzzTime_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	echo "Made by Burrit0z"
	echo "Try not. Do or do not. There is no try."
	echo "Official repo: https://Burrit0z.github.io/repo"
SUBPROJECTS += buzztimeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
