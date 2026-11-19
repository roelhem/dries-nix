# direnv: loads the environment of a project (tools, environment variables)
# automatically when you `cd` into its directory, and unloads it again when
# you leave. A project opts in with an `.envrc` file, which you have to allow
# once with `direnv allow`.
#
# For a nix project, an `.envrc` with just `use flake` is enough.
{ settings, ... }:

{
  programs.direnv = {
    enable = true;

    # Hook direnv into zsh (needs `programs.zsh.enable`, see ./shell.nix).
    enableZshIntegration = true;

    # A faster `use flake` / `use nix` that caches the environment, so it
    # isn't rebuilt every time you enter the directory.
    nix-direnv.enable = true;

    # Settings for ~/.config/direnv/direnv.toml.
    config = {
      # Don't print the full list of changed variables on every `cd`.
      global.hide_env_diff = true;

      # Only warn when loading an environment takes longer than this (the
      # first load of a nix environment can take a while).
      global.warn_timeout = "30s";

      # Trust this repository without `direnv allow`.
      whitelist.prefix = [ settings.configDirectory ];
    };
  };
}
