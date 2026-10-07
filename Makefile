ROCKSPEC := $(firstword $(wildcard ff-lua-*.rockspec))

.PHONY: test
test:
	luarocks test $(ROCKSPEC) -- $(ROCKSPEC) -f -s $(ARGS)

.PHONY: lint
lint:
	luarocks lint $(ROCKSPEC)

.PHONY: install
install:
	luarocks install --deps-only $(ROCKSPEC)

.PHONY: build
build:
	luarocks build --pack-binary-rock

.PHONY: pack
pack:
	luarocks pack $(ROCKSPEC)

.PHONY: publish
publish:
	luarocks upload $(ROCKSPEC) --api-key=$(LUA_ROCKS_API_KEY)
