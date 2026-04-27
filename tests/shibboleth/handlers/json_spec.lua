local h = require('tests.shibboleth.helpers')
local json = require('shibboleth.handlers.json')

local URL = 'https://example.com/schema.json'
local URL2 = 'https://example.com/other.json'

describe('handlers.json', function()
  it('inserts $schema as the first key in a multi-line object', function()
    local b = h.make_buf('{\n  "name": "test"\n}', 'json')
    json.apply(b, URL)
    assert.equals(
      '{\n  "$schema": "https://example.com/schema.json",\n  "name": "test"\n}',
      h.dump(b)
    )
  end)

  it('detects an existing $schema value', function()
    local b = h.make_buf('{\n  "$schema": "' .. URL .. '",\n  "x": 1\n}', 'json')
    local d = json.detect(b)
    assert.equals(URL, d.url)
  end)

  it('updates the value of an existing $schema in place', function()
    local b = h.make_buf('{\n  "$schema": "' .. URL .. '",\n  "x": 1\n}', 'json')
    json.apply(b, URL2)
    assert.equals(
      '{\n  "$schema": "https://example.com/other.json",\n  "x": 1\n}',
      h.dump(b)
    )
  end)

  it('inserts inline into a single-line object', function()
    local b = h.make_buf('{"name": "x"}', 'json')
    json.apply(b, URL)
    assert.equals('{"$schema": "https://example.com/schema.json", "name": "x"}', h.dump(b))
  end)

  it('expands an empty object onto multiple lines', function()
    local b = h.make_buf('{}', 'json')
    json.apply(b, URL)
    assert.equals('{\n  "$schema": "https://example.com/schema.json"\n}', h.dump(b))
  end)

  it('removes the $schema pair and its trailing comma', function()
    local b = h.make_buf('{\n  "$schema": "' .. URL .. '",\n  "name": "test"\n}', 'json')
    json.remove(b)
    assert.equals('{\n  "name": "test"\n}', h.dump(b))
  end)

  it('returns nil from detect when no $schema is present', function()
    local b = h.make_buf('{"name": "x"}', 'json')
    assert.is_nil(json.detect(b))
  end)
end)
