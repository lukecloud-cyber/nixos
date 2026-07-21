{ pkgs, ... }:

{
  # Install the Codex command-line application system-wide.
  environment.systemPackages = [
    pkgs.codex # OpenAI's terminal coding agent.
  ];

  # Keep the user's Codex policy at unrestricted local access after each switch.
  # Existing unrelated TOML settings and tables are preserved.
  system.activationScripts.codexFullAccess = ''
    codex_config=/home/sweet_cicero/.codex/config.toml
    codex_config_dir=$(${pkgs.coreutils}/bin/dirname "$codex_config")

    ${pkgs.coreutils}/bin/install -d -m 0700 -o sweet_cicero -g users "$codex_config_dir"
    ${pkgs.coreutils}/bin/touch "$codex_config"
    ${pkgs.coreutils}/bin/chown sweet_cicero:users "$codex_config"
    ${pkgs.coreutils}/bin/chmod 0600 "$codex_config"

    tmp=$(${pkgs.coreutils}/bin/mktemp)
    ${pkgs.gawk}/bin/awk -v in_top=1 '
      BEGIN {
        print "approval_policy = \"never\""
        print "sandbox_mode = \"danger-full-access\""
      }
      /^\[/ { in_top = 0 }
      in_top == 0 || $0 !~ /^[[:space:]]*(approval_policy|sandbox_mode)[[:space:]]*=/ {
        print
      }
    ' "$codex_config" > "$tmp"

    ${pkgs.coreutils}/bin/mv "$tmp" "$codex_config"
    ${pkgs.coreutils}/bin/chown sweet_cicero:users "$codex_config"
    ${pkgs.coreutils}/bin/chmod 0600 "$codex_config"
  '';
}
