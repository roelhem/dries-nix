# Git, and logging in to the places where the Yielder repositories live:
#   - GitHub Enterprise: https://yielder.ghe.com
#   - Azure DevOps:      https://dev.azure.com (Yieldergroup, venecodev)
#   - GitHub:            https://github.com
#
# After the first switch, log in once with:
#   gh auth login --hostname yielder.ghe.com
#   gh auth login --hostname github.com
# Azure DevOps opens a browser to log in the first time you clone or pull.
{
  lib,
  pkgs,
  settings,
  ...
}:

{
  programs.git = {
    enable = true;

    # Git Large File Storage, used by some repositories for big binary files.
    lfs.enable = true;

    # Settings that end up in ~/.config/git/config.
    settings = {
      # Who you are in your commits.
      user.name = settings.fullName;
      user.email = settings.email;

      # New repositories start on `main` instead of `master`.
      init.defaultBranch = "main";

      # `git push` on a new branch creates it on the remote too, so you don't
      # need `git push --set-upstream origin <branch>`.
      push.autoSetupRemote = true;

      # Azure DevOps: log in through Git Credential Manager, which opens a
      # browser for your Microsoft account and remembers the login in the
      # macOS keychain.
      #
      # This only applies to https://dev.azure.com, so other hosts keep their
      # own helper. The empty string first resets any helper set elsewhere.
      # `useHttpPath` makes it keep a separate login per organisation.
      credential."https://dev.azure.com" = {
        helper = [
          ""
          (lib.getExe pkgs.git-credential-manager)
        ];
        useHttpPath = true;
      };
    };

    # Files that git should ignore in every repository.
    ignores = [
      # macOS
      ".DS_Store"
      # direnv / nix
      "/.direnv/"
      "/result"
      "/result-*"
      # Editors
      ".idea/"
      ".vscode/*"
      "!.vscode/settings.json"
      "!.vscode/tasks.json"
      "!.vscode/launch.json"
      "!.vscode/extensions.json"
    ];
  };

  # The GitHub CLI (`gh`): create pull requests, check CI, ... from the
  # terminal. Also used as the git login for the GitHub hosts below.
  programs.gh = {
    enable = true;

    # Clone over https (works with the `gh` login) instead of ssh.
    settings.git_protocol = "https";

    # Let git use your `gh auth login` to access these hosts.
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
        "https://gist.github.com"
        "https://yielder.ghe.com"
        "https://api.yielder.ghe.com"
      ];
    };
  };
}
