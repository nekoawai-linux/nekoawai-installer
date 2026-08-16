PREFIX ?= /usr
DESTDIR ?=
DISTDIR ?= dist
SOURCE_DATE_EPOCH ?= 1786320000

VERSION := 0.5.0
ARCHIVE := $(DISTDIR)/nekoawai-installer-$(VERSION).tar.gz
SOURCES := LICENSE Makefile README.md nekoawai-install

.PHONY: check install dist

check:
	bash -n nekoawai-install
	# The Live console has the built-in font and nothing else, so anything
	# outside ASCII reaches the screen as garbage.
	! LC_ALL=C grep -n '[^[:print:][:space:]]' nekoawai-install
	# Fifteen hundred lines of bash that partition disks as root deserve more
	# than a syntax check. SC1090 and SC1091 are the files sourced at run
	# time, which are not shellcheck's to resolve.
	@if command -v shellcheck >/dev/null; then \
		shellcheck --shell=bash --exclude=SC1090,SC1091 nekoawai-install; \
	else \
		echo "shellcheck is not installed here; CI runs it"; \
	fi
	./nekoawai-install --version

install:
	install -Dpm 0755 nekoawai-install "$(DESTDIR)$(PREFIX)/bin/nekoawai-install"

dist: check
	mkdir -p "$(DISTDIR)"
	tar --sort=name --owner=0 --group=0 --numeric-owner \
		--mtime="@$(SOURCE_DATE_EPOCH)" \
		--pax-option=delete=atime,delete=ctime \
		--transform='s,^,nekoawai-installer-$(VERSION)/,' \
		-cf - $(SOURCES) | gzip -n > "$(ARCHIVE)"
	sha256sum "$(ARCHIVE)"
