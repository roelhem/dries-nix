{
  lib,
  callPackage,
  # The modules from ./modules.json to install. Dependencies are pulled in
  # automatically, so the default installs the complete Microsoft.Graph bundle.
  #
  #   pkgs.powershell-microsoft-graph.override {
  #     modules = [ "Microsoft.Graph.Users" "Microsoft.Graph.Groups" ];
  #   }
  #
  modules ? [ "Microsoft.Graph" ],
}:

# The Microsoft Graph PowerShell cmdlets, built straight from the PowerShell
# Gallery.
#
# ./modules.json pins the whole dependency closure of the `Microsoft.Graph`
# meta-module and is regenerated with
# `just update-powershell-module Microsoft.Graph`.

callPackage ../build-gallery-bundle.nix { } {
  pname = "powershell-microsoft-graph";
  lockFile = ./modules.json;
  root = "Microsoft.Graph";
  inherit modules;

  meta = {
    description = "Microsoft Graph PowerShell modules for PowerShell Core";
    longDescription = ''
      The Microsoft Graph PowerShell modules, installed under
      `share/powershell/Modules` so that they are picked up through
      `PSModulePath`.
    '';
    homepage = "https://learn.microsoft.com/powershell/microsoftgraph/";
    license = lib.licenses.mit;
  };
}
