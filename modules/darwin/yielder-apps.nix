# The macOS apps needed for working at Yielder.
{ ... }:

{
  # Apps from Homebrew (https://formulae.brew.sh/cask/).
  homebrew.casks = [
    "docker-desktop" # Containers, used by many projects and devcontainers.
    "google-chrome"
    "microsoft-edge"
    "microsoft-teams"
    "microsoft-azure-storage-explorer" # Browse Azure storage accounts.
  ];

  # Apps from the Mac App Store, installed with `mas`. The number is the app
  # id: the digits in the App Store URL of the app
  # (e.g. https://apps.apple.com/app/onedrive/id823766827).
  #
  # You must be signed in to the App Store for this to work.
  homebrew.masApps = {
    "OneDrive" = 823766827;
    "Windows App" = 1295203466; # Remote desktop to Windows machines (formerly "Microsoft Remote Desktop").
    "Microsoft Word" = 462054704;
    "Microsoft Excel" = 462058435;
    "Microsoft PowerPoint" = 462062816;
    "Microsoft Outlook" = 985367838;
    "Microsoft OneNote" = 784801555;
    "Azure VPN Client" = 1553936137; # VPN to the Azure networks.
  };
}
