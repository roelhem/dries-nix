{
  lib,
  callPackage,
  # The modules from ./modules.json to install. Dependencies are pulled in
  # automatically, so the default installs the complete Az bundle.
  #
  #   pkgs.powershell-az.override { modules = [ "Az.Accounts" "Az.Storage" ]; }
  #
  modules ? [ "Az" ],
}:

# The Az (Azure) PowerShell cmdlets, built straight from the PowerShell Gallery.
#
# ./modules.json pins the whole dependency closure of the `Az` meta-module and
# is regenerated with `just update-powershell-module Az`.

callPackage ../build-gallery-bundle.nix { } {
  pname = "powershell-az";
  lockFile = ./modules.json;
  root = "Az";
  inherit modules;

  meta = {
    description = "Azure PowerShell (Az) modules for PowerShell Core";
    longDescription = ''
      The Az PowerShell modules, installed under `share/powershell/Modules` so
      that they are picked up through `PSModulePath`.
    '';
    homepage = "https://learn.microsoft.com/powershell/azure/";
    license = lib.licenses.mit;
  };
}
