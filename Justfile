# Commands to maintain this configuration. Run `just` to list them.

hostname := `nix eval --raw --file ./settings.nix hostname`

# List the available commands.
default:
    @just --list

# Apply the configuration to this Mac.
switch:
    sudo darwin-rebuild switch --flake .#{{ hostname }}

# Build the configuration without applying it (to check for errors).
build:
    darwin-rebuild build --flake .#{{ hostname }}

# Update all inputs (nixpkgs, home-manager, Homebrew, ...) in flake.lock.
update:
    nix flake update

# Re-pin a PowerShell Gallery module (packages/powershell/<module>/modules.json).
update-powershell-module module version='latest':
    python3 ./packages/powershell/update.py {{ module }} --version {{ version }}

# Delete old generations and unused packages from the nix store.
clean:
    sudo nix-collect-garbage --delete-older-than 30d

# Format all nix files.
fmt:
    nix fmt
