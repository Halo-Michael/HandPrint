target ?= iphone:clang::13.1
ARCHS ?= arm64 arm64e
DEBUG ?= no
include $(THEOS)/makefiles/common.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += HandPrint HandPrintKB

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
