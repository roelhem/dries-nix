# .NET: the SDKs, the extra tools, and NuGet access to the Yielder package
# feeds.
{ pkgs, lib, ... }:

let

  # Several .NET SDKs combined into one `dotnet` command. Projects pick the
  # version they need (through their `global.json` or target framework).
  dotnet =
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_11_0
      sdk_10_0
      sdk_9_0
      sdk_8_0
    ];

  # The folder with the actual .NET installation (host/, shared/, sdk/).
  dotnetRoot = "${dotnet}/share/dotnet";

  # Tools installed with `dotnet tool install --global` look for .NET in
  # DOTNET_ROOT_ARM64 (Apple Silicon) or DOTNET_ROOT_X64 (Intel) first.
  dotnetRootArchVar =
    if pkgs.stdenv.hostPlatform.isAarch64 then "DOTNET_ROOT_ARM64" else "DOTNET_ROOT_X64";

  # The NuGet package feeds that `dotnet restore` may download from.
  # `key` is just a name; `value` is the feed URL.
  packageSources = {
    "nuget.org" = "https://api.nuget.org/v3/index.json";
    # The private Yielder (Veneco) packages on Azure DevOps.
    "venecodev" = "https://pkgs.dev.azure.com/venecodev/_packaging/venecodev/nuget/v3/index.json";
    # DevExpress, for projects that use it. The URL contains a personal
    # feed key; get yours from https://nuget.devexpress.com and uncomment:
    # "devexpress" = "https://nuget.devexpress.com/<your-feed-key>/api/v3/index.json";
  };

in

{
  home.packages = [
    dotnet
    pkgs.dotnet-ef # `dotnet ef`: Entity Framework migrations.
    pkgs.azure-functions-core-tools # `func`: run Azure Functions locally.
  ];

  # Make tools from `dotnet tool install --global` available as commands.
  home.sessionPath = [ "$HOME/.dotnet/tools" ];

  home.sessionVariables = {
    # Don't send usage data to Microsoft.
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    # Don't print the welcome banner.
    DOTNET_NOLOGO = "1";
    # Tell .NET (and the tools installed with it) where it is installed.
    DOTNET_ROOT = dotnetRoot;
    ${dotnetRootArchVar} = dotnetRoot;
  };

  # The NuGet configuration (~/.nuget/NuGet/NuGet.config).
  home.file.".nuget/NuGet/NuGet.config" = {
    # Overwrite the file if dotnet created one before.
    force = true;
    text = ''
      <?xml version="1.0" encoding="utf-8"?>
      <configuration>
        <packageSources>
          ${lib.concatStringsSep "\n    " (
            lib.mapAttrsToList (
              key: value: ''<add key="${key}" value="${value}" protocolVersion="3" />''
            ) packageSources
          )}
        </packageSources>
      </configuration>
    '';
  };

  # The Azure Artifacts Credential Provider. NuGet uses it to log in to the
  # Azure DevOps feed (venecodev) above. The first `dotnet restore` asks you
  # to log in with a device code; run it as `dotnet restore --interactive`.
  home.file.".nuget/plugins/netcore/CredentialProvider.Microsoft" = {
    source = "${pkgs.artifacts-credprovider}/lib";
    force = true;
  };
}
