KVER ?= $(shell uname -r)
KDIR ?= /lib/modules/$(KVER)/build

# Kernels built with clang (e.g. CachyOS) need the LLVM toolchain for modules too
ifneq ($(shell grep -s '^CONFIG_CC_IS_CLANG=y' $(KDIR)/.config),)
  LLVM ?= 1
  export LLVM
endif

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
