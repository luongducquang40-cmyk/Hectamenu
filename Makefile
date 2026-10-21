ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard FreeFire

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MyMenu
MyMenu_FILES = Tweak.x
MyMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
