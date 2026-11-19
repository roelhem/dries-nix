# Homebrew, for the macOS apps that are not (or not well) packaged in Nix.
#
# Two parts work together here:
#   - `nix-homebrew` installs Homebrew itself.
#   - `homebrew` (built into nix-darwin) installs the apps you list, on every
#     `darwin-rebuild switch`.
#
# Add apps with `homebrew.casks` / `homebrew.brews` / `homebrew.masApps`
# (see ./yielder-apps.nix for examples), not with `brew install`.
{
  config,
  inputs,
  settings,
  ...
}:

{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    # Install Homebrew.
    enable = true;

    # The user that owns the Homebrew installation.
    user = settings.username;

    # The taps (package lists) Homebrew may use. They come from the flake
    # inputs, so their version is pinned in flake.lock.
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Don't allow `brew tap` by hand; all taps are listed above.
    mutableTaps = false;

    # If Homebrew was already installed before, take it over instead of
    # failing.
    autoMigrate = true;

    # Don't set up a second Homebrew for Intel-only apps (would need Rosetta).
    enableRosetta = false;
  };

  homebrew = {
    # Let nix-darwin install the apps listed in `homebrew.*`.
    enable = true;

    # Tell Homebrew about the taps installed by nix-homebrew above.
    taps = builtins.attrNames config.nix-homebrew.taps;

    # What to do with apps that are installed via Homebrew but NOT listed in
    # this configuration:
    #   "none"      - leave them alone.
    #   "uninstall" - remove them.
    #   "zap"       - remove them, including their settings and caches.
    # "zap" keeps the Mac exactly as described here, but it also means that
    # anything you `brew install` by hand disappears on the next switch. Put
    # it in the configuration instead (or switch to "none").
    onActivation.cleanup = "zap";
  };
}
