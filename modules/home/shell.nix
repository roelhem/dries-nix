# The shell (zsh, the default on macOS).
{ settings, ... }:

{
  # Let home-manager manage ~/.zshrc. This is needed so that the environment
  # variables and tools (direnv, ...) from this configuration get loaded in
  # your terminal. Put your own shell settings here, not in ~/.zshrc directly,
  # because home-manager overwrites that file.
  programs.zsh = {
    enable = true;

    # Suggest commands from your history while typing (accept with →).
    autosuggestion.enable = true;

    # Color commands while typing (red = command not found).
    syntaxHighlighting.enable = true;

    # Short names for commands you use a lot.
    shellAliases = {
      # Apply this configuration after changing it.
      switch = "sudo darwin-rebuild switch --flake ${settings.configDirectory}";
    };
  };
}
