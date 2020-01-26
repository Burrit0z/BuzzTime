include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BuzzTimePrefs

BuzzTimePrefs_FILES = burRootListController.m
BuzzTimePrefs_INSTALL_PATH = /Library/PreferenceBundles
BuzzTimePrefs_FRAMEWORKS = UIKit
BuzzTimePrefs_PRIVATE_FRAMEWORKS = Preferences
BuzzTimePrefs_CFLAGS = -fobjc-arc
BuzzTimePrefs_EXTRA_FRAMEWORKS +=CepheiPrefs Cephei

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BuzzTimePrefs.plist$(ECHO_END)
