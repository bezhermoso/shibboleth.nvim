local h = require('tests.shibboleth.helpers')
local ml = require('shibboleth.handlers.modeline')

describe('handlers.modeline', function()
  it('inserts after a shebang line', function()
    local b = h.make_buf('#!/usr/bin/env ruby\nputs "hi"')
    ml.apply(b, 'ruby')
    assert.equals('#!/usr/bin/env ruby\n# vim: set ft=ruby:\nputs "hi"', h.dump(b))
  end)

  it('inserts at the top when no shebang exists', function()
    local b = h.make_buf('echo hello')
    ml.apply(b, 'sh')
    assert.equals('# vim: set ft=sh:\necho hello', h.dump(b))
  end)

  it('updates ft in an existing modeline preserving other options', function()
    local b = h.make_buf('# vim: set ts=2 ft=lua sw=2:\nlocal x = 1')
    ml.apply(b, 'fennel')
    assert.equals('# vim: set ts=2 ft=fennel sw=2:\nlocal x = 1', h.dump(b))
  end)

  it('detects ft from an existing modeline', function()
    local b = h.make_buf('# vim: set ft=python ts=4:\nprint(1)')
    local d = ml.detect(b)
    assert.equals('python', d.ft)
  end)

  it('appends ft= to an existing modeline that lacks it', function()
    local b = h.make_buf('# vim: set ts=2:\nfoo')
    ml.apply(b, 'ruby')
    local got = h.dump(b)
    assert.is_true(got:find('ft=ruby', 1, true) ~= nil, 'expected ft=ruby in: ' .. got)
  end)

  it('removes a modeline', function()
    local b = h.make_buf('# vim: set ft=ruby:\nputs 1')
    ml.remove(b)
    assert.equals('puts 1', h.dump(b))
  end)

  it('uses commentstring from vim.filetype.get_option for the target filetype', function()
    -- lua's filetype-defined commentstring is `-- %s`
    local b = h.make_buf('local x = 1')
    ml.apply(b, 'lua')
    assert.equals('-- vim: set ft=lua:\nlocal x = 1', h.dump(b))

    -- javascript -> // %s
    local b2 = h.make_buf('let x = 1')
    ml.apply(b2, 'javascript')
    assert.equals('// vim: set ft=javascript:\nlet x = 1', h.dump(b2))

    -- proves the value really came from vim.filetype.get_option, not the fallback
    -- table (which would have used '// %s' for json — but here we ask for 'sql'
    -- which falls back to '-- %s' via Neovim's runtime).
    local b3 = h.make_buf('SELECT 1')
    ml.apply(b3, 'sql')
    local got = h.dump(b3)
    assert.is_true(
      got:match('^%-%- vim: set ft=sql:') ~= nil,
      'expected SQL line-comment prefix, got: ' .. got
    )
  end)
end)
