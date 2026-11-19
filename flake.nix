{
  description = "Nix configuration for Dries' Yielder MacBook";

  # ---------------------------------------------------------------------------
  # INPUTS
  #
  # Everything this configuration depends on. The exact versions are pinned in
  # `flake.lock`; run `just update` (or `nix flake update`) to bump them.
  # ---------------------------------------------------------------------------
  inputs = {
    # The package collection. The `nixpkgs-26.05-darwin` branch is the stable
    # release, tested on macOS.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    # Helps to structure this `flake.nix` (see `outputs` below).
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # nix-darwin: configures macOS itself (system settings, Homebrew, ...).
    # The `follows` makes sure everything uses the same nixpkgs as above.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager: configures your user account (dotfiles, shell, git, ...).
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew: installs Homebrew itself, so you don't have to run the
    # Homebrew install script by hand.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # The Homebrew "taps" (package lists). By pinning them here, Homebrew
    # updates only happen when you update `flake.lock`, not at random.
    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;
    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;
  };

  # ---------------------------------------------------------------------------
  # OUTPUTS
  #
  # What this flake provides. flake-parts splits it into:
  #   - `flake`:     outputs that don't depend on the CPU architecture (the
  #                  macOS configuration itself, the overlay).
  #   - `perSystem`: outputs that exist once per architecture (packages,
  #                  formatter, dev shell).
  # ---------------------------------------------------------------------------
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, ... }:
      let
        # Your personal details (username, hostname, email, ...).
        settings = import ./settings.nix;
      in
      {
        # The architectures this flake builds for. Apple Silicon is
        # `aarch64-darwin`, Intel Macs are `x86_64-darwin`.
        systems = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];

        flake = {
          # Adds the packages from ./packages to `pkgs`, so the modules can use
          # e.g. `pkgs.powershell-az` like any other package.
          overlays.default = import ./packages/overlay.nix;

          # The macOS configuration. Apply it with `just switch`, which runs:
          #   sudo darwin-rebuild switch --flake .#<hostname>
          darwinConfigurations.${settings.hostname} = inputs.nix-darwin.lib.darwinSystem {
            # Extra arguments that every nix-darwin module can ask for.
            specialArgs = { inherit inputs self settings; };
            modules = [ ./hosts/macbook.nix ];
          };
        };

        perSystem =
          { pkgs, ... }:
          let
            # `pkgs` with our own packages added.
            myPkgs = pkgs.extend self.overlays.default;
          in
          {
            # Lets you build the custom packages on their own, which is handy
            # for testing, e.g. `nix build .#powershell-az`.
            packages = {
              inherit (myPkgs)
                artifacts-credprovider
                powershell-az
                powershell-microsoft-graph
                powershell-importexcel
                powershell-simplysql
                ;
            };

            # `nix fmt` formats all nix files in this repository.
            formatter = pkgs.nixfmt-tree;

            # `nix develop` gives you a shell with the tools to maintain this
            # repository (also activated automatically by direnv, see .envrc).
            devShells.default = pkgs.mkShell {
              packages = [
                pkgs.just
                pkgs.nixfmt
                pkgs.nil # Nix language server, for editor support.
                pkgs.python3 # Runs ./packages/powershell/update.py.
              ];
            };
          };
      }
    );
}
