
# All logic is implemented in scripts/make.sh

clean:
	@sh ./scripts/make.sh clean

cross-build: clean
	@sh ./scripts/make.sh cross-build

test: cross-build
	@sh ./scripts/make.sh test

release: test
	@sh ./scripts/make.sh release

local-build: clean
	@sh ./scripts/make.sh local-build

install: local-build
	@sh ./scripts/make.sh install

uninstall:
	@sh ./scripts/make.sh uninstall

.PHONY: clean cross-build test release local-build install uninstall
