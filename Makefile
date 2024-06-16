.PHONY: lint
lint:
	./luarocks lint *.rockspec

.PHONY: install
install:
	./luarocks install --deps-only *.rockspec

.PHONY: build
build:
	./luarocks build --pack-binary-rock
