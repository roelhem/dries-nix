# Settings for Nix itself.
{ settings, ... }:

{
  # Let nix-darwin manage the Nix installation and its settings.
  # Set this to `false` if you installed Nix with the Determinate Systems
  # installer, because that one manages Nix itself.
  nix.enable = true;

  nix.settings = {
    # Turn on flakes and the new `nix` command (`nix build`, `nix develop`, ...).
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Users that may change Nix settings and use extra binary caches. Needed
    # for some `nix develop` setups in projects.
    trusted-users = [
      "root"
      settings.username
    ];
  };

  # Every week, delete things from the Nix store that are no longer used and
  # older than 30 days, so the store does not fill up your disk.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Replace identical files in the Nix store with hard links to save disk space.
  nix.optimise.automatic = true;
}
