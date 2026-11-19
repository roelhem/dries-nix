# Your personal details. This is the only file you need to edit before the
# first `darwin-rebuild switch`; every other file reads its values from here.
#
# (`rec` lets a value refer to another value in this file, like
# `configDirectory` does with `homeDirectory`.)
rec {
  # The name of this Mac in the configuration. It must match the name you pass
  # to `darwin-rebuild --flake .#<hostname>`. Find it with:
  #   scutil --get LocalHostName
  # nix-darwin also sets the computer name to this value.
  hostname = "yielder-dries";

  # Your macOS account name. Find it with: `whoami`
  # Yielder accounts usually look like `Firstname.Lastname`.
  username = "Dries.TODO";

  # Your home directory. Find it with: `echo $HOME`
  homeDirectory = "/Users/Dries.TODO";

  # Where you cloned this repository.
  configDirectory = "${homeDirectory}/dries-nix";

  # Used for your git commits.
  fullName = "Dries TODO";
  email = "dries.todo@yielder.com";

  # The CPU architecture of this Mac: `aarch64-darwin` for Apple Silicon
  # (M1/M2/M3/...), `x86_64-darwin` for an Intel Mac. Check with `uname -m`
  # (`arm64` means Apple Silicon).
  system = "aarch64-darwin";
}
