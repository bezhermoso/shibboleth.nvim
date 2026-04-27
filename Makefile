.PHONY: test test-watch lint clean

NVIM ?= nvim

test:
	$(NVIM) --headless --noplugin -u tests/minimal_init.lua \
		-c "PlenaryBustedDirectory tests/shibboleth/ { minimal_init = 'tests/minimal_init.lua', sequential = true }"

test-watch:
	@command -v entr >/dev/null 2>&1 || { echo 'entr is required: brew install entr'; exit 1; }
	find lua tests -name '*.lua' | entr -c $(MAKE) test

lint:
	@command -v luacheck >/dev/null 2>&1 || { echo 'luacheck not found; skipping'; exit 0; }
	luacheck lua tests --globals vim describe it assert before_each after_each

clean:
	rm -rf .tests
