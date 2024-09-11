# Nuke built-in rules and variables.
MAKEFLAGS += -rR
.SUFFIXES:

# This is the name that our final executable will have.
# Change as needed.
override OUTPUT := kernel

# Convenience macro to reliably declare user overridable variables.
override USER_VARIABLE = $(if $(filter $(origin $(1)),default undefined),$(eval override $(1) := $(2)))

# Target architecture to build for. Default to x86_64.
$(call USER_VARIABLE,KARCH,x86_64)

# Destination directory on install (should always be empty by default).
$(call USER_VARIABLE,DESTDIR,)

# Install prefix; /usr/local is a good, standard default pick.
$(call USER_VARIABLE,PREFIX,/usr/local)

# Check if the architecture is supported.
ifeq ($(filter $(KARCH),aarch64 loongarch64 riscv64 x86_64),)
    $(error Architecture $(KARCH) not supported)
endif

# User controllable C compiler command.
$(call USER_VARIABLE,KCC,clang)

# User controllable C++ compiler command.
$(call USER_VARIABLE,KCXX,clang++)

# User controllable linker command.
$(call USER_VARIABLE,KLD,ld.lld)

# User controllable V command.
$(call USER_VARIABLE,KV,v)

# User controllable C flags.
$(call USER_VARIABLE,KCFLAGS,-g -O2 -pipe)

# User controllable C++ flags. We default to same as C flags.
$(call USER_VARIABLE,KCXXFLAGS,$(KCFLAGS))

# User controllable C/C++ preprocessor flags. We set none by default.
$(call USER_VARIABLE,KCPPFLAGS,)

# User controllable V flags. We set none by default.
$(call USER_VARIABLE,KVFLAGS,)

# User controllable linker flags. We set none by default.
$(call USER_VARIABLE,KLDFLAGS,)

# Internal flags shared by both C and C++ compilers.
override SHARED_FLAGS := \
    -Wall \
    -Wextra \
    -nostdinc \
    -ffreestanding \
    -fno-stack-protector \
    -fno-stack-check \
    -fno-lto \
    -fno-PIC \
    -ffunction-sections \
    -fdata-sections

# Internal C/C++ preprocessor flags that should not be changed by the user.
override KCPPFLAGS := \
    -I c \
    $(KCPPFLAGS) \
    -isystem mlibc/build-$(KARCH)/prefix/include \
    -isystem freestanding-headers \
    -MMD \
    -MP

# Architecture specific internal flags.
ifeq ($(KARCH),x86_64)
    ifeq ($(KCC),clang)
        override KCC += \
            -target x86_64-unknown-none
    endif
    ifeq ($(KCXX),clang++)
        override KCXX += \
            -target x86_64-unknown-none
    endif
    override SHARED_FLAGS += \
        -m64 \
        -march=x86-64 \
        -mno-red-zone \
        -mcmodel=kernel
    override KLDFLAGS += \
        -m elf_x86_64
    override KNASMFLAGS += \
        -f elf64
endif
ifeq ($(KARCH),aarch64)
    ifeq ($(KCC),clang)
        override KCC += \
            -target aarch64-unknown-none
    endif
    ifeq ($(KCXX),clang++)
        override KCXX += \
            -target aarch64-unknown-none
    endif
    override KLDFLAGS += \
        -m aarch64elf
endif
ifeq ($(KARCH),riscv64)
    ifeq ($(KCC),clang)
        override KCC += \
            -target riscv64-unknown-none
    endif
    ifeq ($(shell $(KCC) --version | grep -i 'clang'),)
        override KCFLAGS += \
            -march=rv64imac_zicsr_zifencei
    else
        override KCFLAGS += \
            -march=rv64imac
    endif
    ifeq ($(KCXX),clang++)
        override KCXX += \
            -target riscv64-unknown-none
    endif
    ifeq ($(shell $(KCXX) --version | grep -i 'clang'),)
        override KCXXFLAGS += \
            -march=rv64imac_zicsr_zifencei
    else
        override KCXXFLAGS += \
            -march=rv64imac
    endif
    override SHARED_FLAGS += \
        -mabi=lp64 \
        -mno-relax
    override KLDFLAGS += \
        -m elf64lriscv \
        --no-relax
endif
ifeq ($(KARCH),loongarch64)
    ifeq ($(KCC),clang)
        override KCC += \
            -target loongarch64-unknown-none
    endif
    ifeq ($(KCXX),clang++)
        override KCXX += \
            -target loongarch64-unknown-none
    endif
    override SHARED_FLAGS += \
        -march=loongarch64 \
        -mabi=lp64s
    override KLDFLAGS += \
        -m elf64loongarch \
        --no-relax
endif

override MLIBC_SHARED_FLAGS := \
	-D__thread='' \
	-D_Thread_local='' \
	-D_GNU_SOURCE

override MLIBC_CFLAGS := \
    $(KCFLAGS) \
    $(SHARED_FLAGS) \
    $(MLIBC_SHARED_FLAGS)

override MLIBC_CXXFLAGS := \
    $(KCXXFLAGS) \
    $(SHARED_FLAGS) \
    -fno-rtti \
    -fno-exceptions \
    $(MLIBC_SHARED_FLAGS)

# Internal C flags that should not be changed by the user.
override KCFLAGS += \
    -std=gnu99 \
    $(SHARED_FLAGS)

obj-$(KARCH)/flanterm/backends/fb.c.o: override KCPPFLAGS += \
    -DFLANTERM_FB_DISABLE_BUMP_ALLOC

# Internal linker flags that should not be changed by the user.
override KLDFLAGS += \
    -nostdlib \
    -static \
    -z max-page-size=0x1000 \
    -gc-sections \
    -T linker-$(KARCH).ld

override KVFLAGS += \
    -os vinix \
    -enable-globals \
    -nofloat \
    -manualfree \
    -experimental \
    -message-limit 10000 \
    -gc none \
    -d no_backtrace

# Use "find" to glob all *.v, *.c, and *.S files in the tree and obtain the
# object and header dependency file names.
override VFILES := $(shell find -L * -type f -name '*.v' | LC_ALL=C sort)
override CFILES := $(shell cd c && find -L * -type f -name '*.c' | LC_ALL=C sort)
override ASFILES := $(shell cd asm && find -L * -type f -name '*.S' | LC_ALL=C sort)
override OBJ := $(addprefix obj-$(KARCH)/,$(CFILES:.c=.c.o) $(ASFILES:.S=.S.o))
override HEADER_DEPS := $(addprefix obj-$(KARCH)/,$(CFILES:.c=.c.d) $(ASFILES:.S=.S.d))

# Ensure the dependencies have been obtained.
override MISSING_DEPS := $(shell if ! test -d freestanding-headers || ! test -f c/cc-runtime.c || ! test -d c/flanterm || ! test -d mlibc; then echo 1; fi)
ifeq ($(MISSING_DEPS),1)
    $(error Please run the ./get-deps script first)
endif

# Default target.
.PHONY: all
all: bin-$(KARCH)/$(OUTPUT)

# Link rules for the final executable.
bin-$(KARCH)/$(OUTPUT): GNUmakefile linker-$(KARCH).ld obj-$(KARCH)/blob.c.o mlibc/build-$(KARCH)/libc.a $(OBJ)
	mkdir -p "$$(dirname $@)"
	$(KLD) obj-$(KARCH)/blob.c.o mlibc/build-$(KARCH)/libc.a $(OBJ) $(KLDFLAGS) -o $@

obj-$(KARCH)/blob.c.o: mlibc/build-$(KARCH)/libc.a $(VFILES)
	mkdir -p "$$(dirname $@)"
	$(KV) $(KVFLAGS) -o obj-$(KARCH)/blob.c .
	sed 's/call 0(/call *(/g' < obj-$(KARCH)/blob.c > obj-$(KARCH)/blob.c.tmp
	mv obj-$(KARCH)/blob.c.tmp obj-$(KARCH)/blob.c
	$(KCC) $(KCFLAGS) $(KCPPFLAGS) -w -c obj-$(KARCH)/blob.c -o $@

# Include header dependencies.
-include $(HEADER_DEPS)

# Compilation rules for *.c files.
obj-$(KARCH)/%.c.o: c/%.c mlibc/build-$(KARCH)/libc.a GNUmakefile
	mkdir -p "$$(dirname $@)"
	$(KCC) $(KCFLAGS) $(KCPPFLAGS) -c $< -o $@

# Compilation rules for *.S files.
obj-$(KARCH)/%.S.o: asm/%.S mlibc/build-$(KARCH)/libc.a GNUmakefile
	mkdir -p "$$(dirname $@)"
	$(KCC) $(KCFLAGS) $(KCPPFLAGS) -c $< -o $@

.PHONY: mlibc
mlibc:
	rm -f mlibc/build-$(KARCH)/libc.a
	$(MAKE) mlibc/build-$(KARCH)/libc.a

mlibc/build-$(KARCH)/libc.a:
	ARCH="$(KARCH)" \
	CFLAGS="$(MLIBC_CFLAGS)" \
	CXXFLAGS="$(MLIBC_CXXFLAGS)" \
	CC="$(KCC)" \
	CXX="$(KCXX)" \
		./build-mlibc

# Remove object files and the final executable.
.PHONY: clean
clean:
	rm -rf bin-$(KARCH) obj-$(KARCH)

# Remove everything built and generated including downloaded dependencies.
.PHONY: distclean
distclean:
	rm -rf bin-* obj-* freestanding-headers c/cc-runtime.c c/flanterm mlibc

# Install the final built executable to its final on-root location.
.PHONY: install
install: all
	install -d "$(DESTDIR)$(PREFIX)/share/$(OUTPUT)"
	install -m 644 bin-$(KARCH)/$(OUTPUT) "$(DESTDIR)$(PREFIX)/share/$(OUTPUT)/$(OUTPUT)-$(KARCH)"

# Try to undo whatever the "install" target did.
.PHONY: uninstall
uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/share/$(OUTPUT)/$(OUTPUT)-$(KARCH)"
	-rmdir "$(DESTDIR)$(PREFIX)/share/$(OUTPUT)"
