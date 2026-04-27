local registry = require('shibboleth.registry')

describe('registry.match_path', function()
  it('matches package.json by basename', function()
    local hits = registry.match_path('/tmp/proj/package.json')
    assert.equals('npm-package', hits[1].schema_id)
  end)

  it('matches a brace-expanded glob', function()
    local cwd = vim.fn.getcwd()
    local hits = registry.match_path(cwd .. '/.github/workflows/ci.yml')
    assert.equals('github-workflow', hits[1].schema_id)
  end)

  it('returns empty for unknown paths', function()
    local hits = registry.match_path('/tmp/proj/something.xyz')
    assert.equals(0, #hits)
  end)

  it('returns empty for empty path', function()
    assert.equals(0, #registry.match_path(''))
    assert.equals(0, #registry.match_path(nil))
  end)
end)

describe('registry.schemas_for_ft', function()
  it('lists json schemas for filetype "json"', function()
    local list = registry.schemas_for_ft('json')
    assert.is_true(#list > 0)
    for _, s in ipairs(list) do
      assert.is_true(vim.tbl_contains(s.schema.ft, 'json'))
    end
  end)

  it('returns sorted by name', function()
    local list = registry.schemas_for_ft('yaml')
    for i = 2, #list do
      assert.is_true(list[i - 1].schema.name <= list[i].schema.name)
    end
  end)
end)

describe('registry.match_path with ** globs', function()
  before_each(function()
    registry.schemas['__test'] = { name = 'Test', url = 'https://x', ft = { 'json' } }
  end)

  after_each(function()
    registry.schemas['__test'] = nil
    -- Drop test patterns added in each `it` block.
    for i = #registry.patterns, 1, -1 do
      if registry.patterns[i].schema == '__test' then
        table.remove(registry.patterns, i)
      end
    end
  end)

  it('** matches at any depth in the relative path', function()
    table.insert(registry.patterns, { pattern = '**/skill.json', schema = '__test' })
    local cwd = vim.fn.getcwd()
    assert.equals('__test', registry.match_path(cwd .. '/foo/skill.json')[1].schema_id)
    assert.equals('__test', registry.match_path(cwd .. '/a/b/c/skill.json')[1].schema_id)
    assert.equals('__test', registry.match_path(cwd .. '/skill.json')[1].schema_id)
    assert.equals(0, #registry.match_path(cwd .. '/skill.txt'))
  end)

  it('** segments inside the glob match across directories', function()
    table.insert(registry.patterns, { pattern = 'src/**/config.json', schema = '__test' })
    local cwd = vim.fn.getcwd()
    assert.equals('__test', registry.match_path(cwd .. '/src/config.json')[1].schema_id)
    assert.equals('__test', registry.match_path(cwd .. '/src/a/b/config.json')[1].schema_id)
    assert.equals(0, #registry.match_path(cwd .. '/lib/config.json'))
  end)

  it('* in a basename glob does not cross path separators', function()
    table.insert(registry.patterns, { pattern = '*.json', schema = '__test' })
    local cwd = vim.fn.getcwd()
    -- Basename-mode glob matches against basename only, never directory parts.
    assert.equals('__test', registry.match_path(cwd .. '/anywhere/file.json')[1].schema_id)
    assert.equals(0, #registry.match_path(cwd .. '/anywhere/file.txt'))
  end)
end)

describe('registry.extend', function()
  it('merges user schemas and patterns', function()
    local before = vim.tbl_count(registry.schemas)
    registry.extend({
      schemas = { ['custom-test'] = { name = 'Test', url = 'https://x', ft = { 'json' } } },
      patterns = { { pattern = 'custom-test.json', schema = 'custom-test' } },
    })
    assert.equals(before + 1, vim.tbl_count(registry.schemas))
    local hits = registry.match_path('/tmp/custom-test.json')
    assert.equals('custom-test', hits[1].schema_id)
    -- cleanup
    registry.schemas['custom-test'] = nil
  end)
end)
