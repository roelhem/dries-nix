# Your user configuration (home-manager). This file loads the separate parts
# and holds the general settings.
{ pkgs, settings, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./direnv.nix
    ./dotnet.nix
    ./azure.nix
    ./powershell.nix
  ];

  home.username = settings.username;
  home.homeDirectory = settings.homeDirectory;

  # Command line tools to install for your user. Search for more packages on
  # https://search.nixos.org/packages.
  home.packages = [
    pkgs.just # Runs the commands in a `Justfile` (like the one in this repo).
    pkgs.jq # Work with JSON on the command line.
    pkgs.sqlcmd # Query SQL Server / Azure SQL databases.
  ];

  # Your default email address, picked up by some tools.
  home.sessionVariables.EMAIL = settings.email;

  # The home-manager release this configuration was first written for. Do NOT
  # change this when you update; it is only there so home-manager can keep
  # old behaviour where defaults have changed since.
  home.stateVersion = "26.05";
}
