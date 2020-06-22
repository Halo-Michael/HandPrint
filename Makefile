target ?= iphone:clang::13.0
ARCHS ?= arm64 arm64e
DEBUG ?= no
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = HandPrint
HandPrint_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
