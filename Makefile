.PHONY: test
test:
	# -f => fails fast, stops at first test failure
	# -s => shuffles the execution order
	# -v => verbose 
	luarocks test -- -f -s -v $(ARGS)

.PHONY: lint
lint:
	luarocks lint *.rockspec

.PHONY: install
install:
	luarocks install --deps-only *.rockspec

.PHONY: build
build:
	luarocks build --pack-binary-rock

.PHONY: pack
pack:
	luarocks pack *.rockspec

.PHONY: publish
publish:
	luarocks upload *.rockspec --api-key=$(LUA_ROCKS_API_KEY)
