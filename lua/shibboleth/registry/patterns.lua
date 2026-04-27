---@class ShibbolethPattern
---@field pattern string   Glob (Lua filetype-style) matched against full path or basename.
---@field schema string    Key in registry/schemas.lua.

---@type ShibbolethPattern[]
return {
  { pattern = 'package.json',                       schema = 'npm-package' },
  { pattern = 'tsconfig*.json',                     schema = 'tsconfig' },
  { pattern = 'jsconfig*.json',                     schema = 'tsconfig' },
  { pattern = 'composer.json',                      schema = 'composer' },

  { pattern = '.eslintrc',                          schema = 'eslintrc' },
  { pattern = '.eslintrc.json',                     schema = 'eslintrc' },
  { pattern = '.eslintrc.{yml,yaml}',               schema = 'eslintrc' },
  { pattern = '.prettierrc',                        schema = 'prettierrc' },
  { pattern = '.prettierrc.json',                   schema = 'prettierrc' },
  { pattern = '.prettierrc.{yml,yaml}',             schema = 'prettierrc' },
  { pattern = '.babelrc',                           schema = 'babelrc' },
  { pattern = '.babelrc.json',                      schema = 'babelrc' },
  { pattern = '.stylelintrc',                       schema = 'stylelintrc' },
  { pattern = '.stylelintrc.{json,yml,yaml}',       schema = 'stylelintrc' },

  { pattern = 'renovate.json',                      schema = 'renovate' },
  { pattern = '.renovaterc',                        schema = 'renovate' },
  { pattern = '.renovaterc.json',                   schema = 'renovate' },

  { pattern = 'lefthook.{yml,yaml}',                schema = 'lefthook' },
  { pattern = '.pre-commit-config.{yml,yaml}',      schema = 'pre-commit' },

  { pattern = '.github/workflows/*.{yml,yaml}',     schema = 'github-workflow' },
  { pattern = 'action.{yml,yaml}',                  schema = 'github-action' },
  { pattern = '**/.gitlab-ci.{yml,yaml}',           schema = 'gitlab-ci' },
  { pattern = '**/*.gitlab-ci.{yml,yaml}',          schema = 'gitlab-ci' },

  { pattern = 'playbook.{yml,yaml}',                schema = 'ansible-playbook' },
  { pattern = 'site.{yml,yaml}',                    schema = 'ansible-playbook' },
  { pattern = '**/playbooks/*.{yml,yaml}',          schema = 'ansible-playbook' },
  { pattern = '.circleci/config.{yml,yaml}',        schema = 'circleci' },

  { pattern = 'docker-compose*.{yml,yaml}',         schema = 'docker-compose' },
  { pattern = 'compose.{yml,yaml}',                 schema = 'docker-compose' },
  { pattern = 'compose.*.{yml,yaml}',               schema = 'docker-compose' },

  { pattern = '.github/dependabot.{yml,yaml}',      schema = 'dependabot' },
  { pattern = 'mkdocs.{yml,yaml}',                  schema = 'mkdocs' },

  { pattern = 'pyproject.toml',                     schema = 'pyproject' },
  { pattern = 'Cargo.toml',                         schema = 'cargo' },
  { pattern = 'rustfmt.toml',                       schema = 'rustfmt' },
  { pattern = '.rustfmt.toml',                      schema = 'rustfmt' },
  { pattern = '.taplo.toml',                        schema = 'taplo' },
  { pattern = 'taplo.toml',                         schema = 'taplo' },

  -- AI coding tools
  { pattern = '**/.claude/settings.json',           schema = 'claude-code-settings' },
  { pattern = '**/.claude/settings.local.json',     schema = 'claude-code-settings' },
  { pattern = '**/.claude/keybindings.json',        schema = 'claude-code-keybindings' },
  { pattern = '**/.claude-plugin/plugin.json',      schema = 'claude-code-plugin' },
  { pattern = '**/.claude-plugin/marketplace.json', schema = 'claude-code-marketplace' },
  -- See https://github.com/bezhermoso/claude-mergerc
  { pattern = '**/.config/claude/fragments/*.json', schema = 'claude-code-settings' },
  { pattern = '**/.codex/config.toml',              schema = 'codex-cli' },
  { pattern = '.aider.conf.{yml,yaml}',             schema = 'aider' },
  { pattern = '.roomodes',                          schema = 'roo-code' },
  { pattern = '*.roomodes',                         schema = 'roo-code' },
  { pattern = 'custom_modes.{yml,yaml}',            schema = 'roo-code' },
  { pattern = '**/.cursor/environment.json',        schema = 'cursor-environment' },
  { pattern = '**/.continue/config.json',           schema = 'continue-config' },
  { pattern = '.mcp.json',                          schema = 'mcp-server' },
  { pattern = 'mcp_config.json',                    schema = 'mcp-server' },
  { pattern = 'cline_mcp_settings.json',            schema = 'mcp-server' },
  { pattern = 'claude_desktop_config.json',         schema = 'mcp-server' },
}
