
# All logic is implemented in scripts/make.sh

clean:
	@sh ./scripts/make.sh clean

cross-build: clean
	@sh ./scripts/make.sh cross-build

test: cross-build
	@sh ./scripts/make.sh test

local-build: clean
	@sh ./scripts/make.sh local-build

install: local-build
	@sh ./scripts/make.sh install

uninstall:
	@sh ./scripts/make.sh uninstall

.PHONY: local-build cross-build install test uninstall clean
