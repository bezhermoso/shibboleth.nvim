---@class ShibbolethSchema
---@field name string  Human-readable label shown in pickers.
---@field url string   Schema URL written into the directive.
---@field ft string[]  Filetypes this schema applies to.

---@type table<string, ShibbolethSchema>
return {
  ['npm-package'] = {
    name = 'package.json (npm)',
    url = 'https://json.schemastore.org/package.json',
    ft = { 'json' },
  },
  ['tsconfig'] = {
    name = 'tsconfig.json',
    url = 'https://json.schemastore.org/tsconfig.json',
    ft = { 'json' },
  },
  ['composer'] = {
    name = 'composer.json',
    url = 'https://getcomposer.org/schema.json',
    ft = { 'json' },
  },
  ['eslintrc'] = {
    name = 'ESLint config',
    url = 'https://json.schemastore.org/eslintrc.json',
    ft = { 'json', 'yaml' },
  },
  ['prettierrc'] = {
    name = 'Prettier config',
    url = 'https://json.schemastore.org/prettierrc.json',
    ft = { 'json', 'yaml' },
  },
  ['babelrc'] = {
    name = 'Babel config',
    url = 'https://json.schemastore.org/babelrc.json',
    ft = { 'json' },
  },
  ['stylelintrc'] = {
    name = 'Stylelint config',
    url = 'https://json.schemastore.org/stylelintrc.json',
    ft = { 'json', 'yaml' },
  },
  ['renovate'] = {
    name = 'Renovate config',
    url = 'https://docs.renovatebot.com/renovate-schema.json',
    ft = { 'json' },
  },
  ['lefthook'] = {
    name = 'Lefthook config',
    url = 'https://json.schemastore.org/lefthook.json',
    ft = { 'yaml' },
  },
  ['pre-commit'] = {
    name = 'pre-commit config',
    url = 'https://json.schemastore.org/pre-commit-config.json',
    ft = { 'yaml' },
  },
  ['github-workflow'] = {
    name = 'GitHub Actions workflow',
    url = 'https://json.schemastore.org/github-workflow.json',
    ft = { 'yaml' },
  },
  ['github-action'] = {
    name = 'GitHub Action metadata',
    url = 'https://json.schemastore.org/github-action.json',
    ft = { 'yaml' },
  },
  ['gitlab-ci'] = {
    name = 'GitLab CI',
    url = 'https://gitlab.com/gitlab-org/gitlab-foss/-/raw/master/app/assets/javascripts/editor/schema/ci.json',
    ft = { 'yaml' },
  },
  ['circleci'] = {
    name = 'CircleCI config',
    url = 'https://json.schemastore.org/circleciconfig.json',
    ft = { 'yaml' },
  },
  ['docker-compose'] = {
    name = 'docker-compose',
    url = 'https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json',
    ft = { 'yaml' },
  },
  ['dependabot'] = {
    name = 'Dependabot v2',
    url = 'https://json.schemastore.org/dependabot-2.0.json',
    ft = { 'yaml' },
  },
  ['mkdocs'] = {
    name = 'MkDocs config',
    url = 'https://json.schemastore.org/mkdocs-1.6.json',
    ft = { 'yaml' },
  },
  ['ansible-playbook'] = {
    name = 'Ansible playbook',
    url = 'https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/playbook',
    ft = { 'yaml' },
  },
  ['openapi-3'] = {
    name = 'OpenAPI 3.x',
    url = 'https://spec.openapis.org/oas/3.1/schema/2022-10-07',
    ft = { 'json', 'yaml' },
  },
  ['jsonschema-2020-12'] = {
    name = 'JSON Schema (2020-12)',
    url = 'https://json-schema.org/draft/2020-12/schema',
    ft = { 'json' },
  },
  ['jsonschema-draft-7'] = {
    name = 'JSON Schema (draft-07)',
    url = 'https://json-schema.org/draft-07/schema',
    ft = { 'json' },
  },
  ['pyproject'] = {
    name = 'pyproject.toml',
    url = 'https://json.schemastore.org/pyproject.json',
    ft = { 'toml' },
  },
  ['cargo'] = {
    name = 'Cargo.toml',
    url = 'https://json.schemastore.org/cargo.json',
    ft = { 'toml' },
  },
  ['rustfmt'] = {
    name = 'rustfmt.toml',
    url = 'https://json.schemastore.org/rustfmt.json',
    ft = { 'toml' },
  },
  ['taplo'] = {
    name = 'Taplo config',
    url = 'https://json.schemastore.org/taplo.json',
    ft = { 'toml' },
  },

  -- AI coding tools
  ['claude-code-settings'] = {
    name = 'Claude Code settings',
    url = 'https://www.schemastore.org/claude-code-settings.json',
    ft = { 'json' },
  },
  ['claude-code-keybindings'] = {
    name = 'Claude Code keybindings',
    url = 'https://www.schemastore.org/claude-code-keybindings.json',
    ft = { 'json' },
  },
  ['claude-code-plugin'] = {
    name = 'Claude Code plugin manifest',
    url = 'https://www.schemastore.org/claude-code-plugin-manifest.json',
    ft = { 'json' },
  },
  ['claude-code-marketplace'] = {
    name = 'Claude Code plugin marketplace',
    url = 'https://www.schemastore.org/claude-code-marketplace.json',
    ft = { 'json' },
  },
  ['codex-cli'] = {
    name = 'OpenAI Codex CLI config',
    url = 'https://developers.openai.com/codex/config-schema.json',
    ft = { 'toml' },
  },
  ['aider'] = {
    name = 'Aider config',
    url = 'https://www.schemastore.org/aider-0.82.json',
    ft = { 'yaml' },
  },
  ['roo-code'] = {
    name = 'Roo Code custom modes',
    url = 'https://www.schemastore.org/roomodes.json',
    ft = { 'yaml' },
  },
  ['cursor-environment'] = {
    name = 'Cursor agent environment',
    url = 'https://cursor.com/schemas/environment.schema.json',
    ft = { 'json' },
  },
  ['continue-config'] = {
    name = 'Continue.dev config',
    url = 'https://raw.githubusercontent.com/continuedev/continue/main/extensions/vscode/config_schema.json',
    ft = { 'json' },
  },
  ['mcp-server'] = {
    name = 'MCP server config',
    url = 'https://raw.githubusercontent.com/modelcontextprotocol/specification/main/schema/2025-06-18/schema.json',
    ft = { 'json' },
  },
}
