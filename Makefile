.PHONY: test test-watch lint clean deps

NVIM        ?= nvim
LAZY        := $(HOME)/.local/share/nvim/lazy
PLENARY     := $(LAZY)/plenary.nvim
TREESITTER  := $(LAZY)/nvim-treesitter
JSON_PARSER := $(TREESITTER)/parser/json.so

deps: $(PLENARY) $(JSON_PARSER)

$(PLENARY):
	@mkdir -p $(LAZY)
	git clone --depth=1 https://github.com/nvim-lua/plenary.nvim $@

$(TREESITTER):
	@mkdir -p $(LAZY)
	git clone --depth=1 https://github.com/nvim-treesitter/nvim-treesitter $@

$(JSON_PARSER): | $(TREESITTER)
	@TSJ=$$(mktemp -d); \
	  echo "Building JSON tree-sitter parser..."; \
	  git clone --depth=1 https://github.com/tree-sitter/tree-sitter-json $$TSJ; \
	  mkdir -p $(dir $@); \
	  cc -O2 -shared -fPIC -o $@ $$TSJ/src/parser.c -I$$TSJ/src; \
	  rm -rf $$TSJ

test: deps
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
