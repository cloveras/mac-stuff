# ~/.zshenv — sourced by EVERY zsh invocation (login, interactive, non-interactive,
# scripts). Unlike ~/.zshrc (interactive-only), this reaches child processes such as
# the GitHub MCP server that Claude Code spawns, regardless of how Claude was launched.

# GitHub MCP server (claude-plugins-official) reads this for its Bearer header.
# Resolved live from the gh CLI keyring, so no token is written to disk.
export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
