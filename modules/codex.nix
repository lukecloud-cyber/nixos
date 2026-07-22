{ pkgs, ... }:

{
  # Install the Codex command-line application system-wide.
  environment.systemPackages = [
    pkgs.codex # OpenAI's terminal coding agent.
  ];

  # Provide reproducible defaults while leaving ~/.codex/config.toml writable
  # for Codex-managed marketplace, plugin, and hook state.
  environment.etc."codex/config.toml".text = ''
    approval_policy = "never"
    sandbox_mode = "danger-full-access"
    model = "gpt-5.6-sol"
    model_reasoning_effort = "xhigh"

    [projects."/home/sweet_cicero"]
    trust_level = "trusted"

    [projects."/home/sweet_cicero/Projects/reversing"]
    trust_level = "trusted"

    [tui]
    status_line = ["model-with-reasoning", "current-dir", "context-used", "weekly-limit", "fast-mode"]
    status_line_use_colors = true

    [mcp_servers.nixos]
    command = "nix"
    args = ["run", "github:utensils/mcp-nixos", "--"]
  '';
}
