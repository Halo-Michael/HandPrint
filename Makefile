target ?= iphone:clang::13.0
ARCHS ?= arm64
DEBUG ?= no
include $(THEOS)/makefiles/common.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += HandPrint HandPrintKB

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
