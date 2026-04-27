local h = require('tests.shibboleth.helpers')
local toml = require('shibboleth.handlers.toml')

local URL = 'https://example.com/schema.json'
local URL2 = 'https://example.com/other.json'

describe('handlers.toml', function()
  it('inserts a #:schema directive at the top', function()
    local b = h.make_buf('[package]\nname = "x"', 'toml')
    toml.apply(b, URL)
    assert.equals(
      '#:schema https://example.com/schema.json\n[package]\nname = "x"',
      h.dump(b)
    )
  end)

  it('updates an existing directive in place', function()
    local b = h.make_buf('#:schema ' .. URL .. '\n[package]\nname = "x"', 'toml')
    toml.apply(b, URL2)
    assert.equals(
      '#:schema https://example.com/other.json\n[package]\nname = "x"',
      h.dump(b)
    )
  end)

  it('removes an existing directive', function()
    local b = h.make_buf('#:schema ' .. URL .. '\n[package]', 'toml')
    toml.remove(b)
    assert.equals('[package]', h.dump(b))
  end)

  it('does not pick up #:schema buried below non-comment lines', function()
    local b = h.make_buf('[package]\n#:schema ' .. URL, 'toml')
    assert.is_nil(toml.detect(b))
  end)
end)
