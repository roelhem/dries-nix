# The macOS (nix-darwin) configuration of the MacBook. This file glues
# everything together: it loads the system modules and hooks home-manager in
# for your user account.
{
  inputs,
  self,
  settings,
  ...
}:

{
  imports = [
    # Lets nix-darwin manage home-manager, so one `darwin-rebuild switch`
    # updates both the system and your user configuration.
    inputs.home-manager.darwinModules.home-manager

    ../modules/darwin/nix.nix
    ../modules/darwin/homebrew.nix
    ../modules/darwin/yielder-apps.nix
  ];

  # --- Machine ---------------------------------------------------------------

  # The CPU architecture (see settings.nix).
  nixpkgs.hostPlatform = settings.system;

  # Allow packages with a non-open-source license.
  nixpkgs.config.allowUnfree = true;

  # Make our own packages (./packages) available as `pkgs.<name>`.
  nixpkgs.overlays = [ self.overlays.default ];

  # The name of this Mac, as shown in Finder, AirDrop and on the network.
  networking.hostName = settings.hostname;
  networking.computerName = settings.hostname;

  # --- User --------------------------------------------------------------------

  # Tell nix-darwin about your (already existing) macOS account. This does
  # not create the account; it only lets home-manager find it.
  users.users.${settings.username} = {
    name = settings.username;
    home = settings.homeDirectory;
  };

  # Some settings (like Homebrew) are applied as a specific user rather than
  # as root. That is you.
  system.primaryUser = settings.username;

  # Make zsh (the default macOS shell) load the nix environment.
  programs.zsh.enable = true;

  # --- home-manager --------------------------------------------------------

  home-manager = {
    # Use the same `pkgs` as the system (including our overlay and the
    # allowUnfree setting) instead of a separate copy.
    useGlobalPkgs = true;

    # Install your packages in /etc/profiles/per-user/<you> instead of
    # ~/.nix-profile.
    useUserPackages = true;

    # When home-manager wants to manage a file that already exists (like the
    # ~/.zshrc that macOS created), rename the old one to `<file>.backup`
    # instead of failing.
    backupFileExtension = "backup";

    # Extra arguments that every home-manager module can ask for.
    extraSpecialArgs = { inherit inputs settings; };

    # Your user configuration lives in ../modules/home.
    users.${settings.username} = import ../modules/home;
  };

  # --- Versions ------------------------------------------------------------

  # The nix-darwin release this configuration was first written for. Do NOT
  # change this when you update; it is only there so nix-darwin can keep old
  # behaviour where defaults have changed since.
  system.stateVersion = 7;
}
