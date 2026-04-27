local h = require('tests.shibboleth.helpers')
local yaml = require('shibboleth.handlers.yaml')

local URL = 'https://example.com/schema.json'
local URL2 = 'https://example.com/other.json'

describe('handlers.yaml', function()
  it('inserts a yaml-language-server modeline at the top', function()
    local b = h.make_buf('name: test\nfoo: bar', 'yaml')
    yaml.apply(b, URL)
    assert.equals(
      '# yaml-language-server: $schema=https://example.com/schema.json\nname: test\nfoo: bar',
      h.dump(b)
    )
  end)

  it('updates an existing modeline in place', function()
    local b = h.make_buf('# yaml-language-server: $schema=' .. URL .. '\nfoo: bar', 'yaml')
    yaml.apply(b, URL2)
    assert.equals(
      '# yaml-language-server: $schema=https://example.com/other.json\nfoo: bar',
      h.dump(b)
    )
  end)

  it('preserves IntelliJ-style directive on update', function()
    local b = h.make_buf('# $schema: ' .. URL .. '\nfoo: bar', 'yaml')
    yaml.apply(b, URL2)
    assert.equals(
      '# $schema: https://example.com/other.json\nfoo: bar',
      h.dump(b)
    )
  end)

  it('inserts after a leading --- document marker', function()
    local b = h.make_buf('---\nname: test', 'yaml')
    yaml.apply(b, URL)
    assert.equals(
      '---\n# yaml-language-server: $schema=https://example.com/schema.json\nname: test',
      h.dump(b)
    )
  end)

  it('removes an existing directive', function()
    local b = h.make_buf('# yaml-language-server: $schema=' .. URL .. '\nfoo: bar', 'yaml')
    yaml.remove(b)
    assert.equals('foo: bar', h.dump(b))
  end)

  it('returns nil from detect when nothing matches', function()
    local b = h.make_buf('foo: bar', 'yaml')
    assert.is_nil(yaml.detect(b))
  end)
end)
